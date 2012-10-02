class c2corg::syslog::pgfouine {

  package { ["pgfouine"]: ensure => present }

  $pgfouinemem = "2048M"

  file { "/var/www/${fqdn}/htdocs/pgfouine": ensure => directory }

  tidy { "/var/www/${fqdn}/htdocs/pgfouine":
    age     => "2w",
    type    => "mtime",
    recurse => true,
  }


  # TODO: fix this:
  # PHP Fatal error:  Class 'awVera' not found in /usr/share/pgfouine/include/reporting/artichow/php5/Graph.class.php on line 133
  file { "/srv/syslog/postgresql/processlog":
    ensure  => present,
    mode    => 0755,
    content => "#!/usr/sbin/logrotate

# file managed by puppet

/srv/syslog/postgresql/prod.log {
  size 1k
  rotate 50
  compress
  delaycompress
  postrotate
    /usr/sbin/invoke-rc.d syslog-ng reload >/dev/null
    /usr/bin/nice -n 19 /usr/bin/pgfouine -file /srv/syslog/postgresql/prod.log.1 -top 30 -format html -memorylimit ${pgfouinemem} -report /var/www/${fqdn}/htdocs/pgfouine/$(date +%Y%m%d-%Hh%Mm).html=overall,hourly,bytype,slowest,n-mosttime,n-mostfrequent,n-slowestaverage,n-mostfrequenterrors 2>&1 | logger -t pgfouine
  endscript
}
",
  }

  augeas { 'increase php-cli memory limit for pgfouine':
    changes => "set PHP/memory_limit ${pgfouinemem}",
    incl    => '/etc/php5/cli/php.ini',
    lens    => 'PHP.lns',
  }

  augeas { 'prevent suhosin from loading':
    changes => 'rm .anon/extension',
    incl    => '/etc/php5/conf.d/suhosin.ini',
    lens    => 'PHP.lns',
  }

  cron { "rotate and process postgresql logs":
    command => "/srv/syslog/postgresql/processlog",
    user    => "root",
    hour    => 6, # avoid overlap with haproxy
    minute  => 0,
    require => File["/srv/syslog/postgresql/processlog"],
  }

}
