class c2corg::syslog::haproxy {

  file { "/var/www/haproxy-logs": ensure => directory }

  tidy { "/var/www/haproxy-logs":
    age     => "2w",
    type    => "mtime",
    recurse => true,
  }

  # TODO: install request-log-analyzer

  file { "/srv/syslog/haproxy/processlog":
    ensure  => present,
    mode    => 0755,
    content => "#!/usr/sbin/logrotate

# file managed by puppet

/srv/syslog/haproxy/prod.log {
  size 1k
  rotate 50
  compress
  delaycompress
  postrotate
    /usr/sbin/invoke-rc.d syslog-ng reload >/dev/null
    RUBYLIB=/srv/syslog/haproxy/request-log-analyzer/lib/ time nice -n 19 ruby1.8 /srv/syslog/haproxy/request-log-analyzer/bin/request-log-analyzer --format /srv/syslog/haproxy/haproxy.rb --output html --report-amount 50 --silent --file /var/www/haproxy-logs/$(date +%Y%m%d-%Hh%Mm).html /srv/syslog/haproxy/prod.log.1 2>&1 | logger -t RLA
  endscript
}
",
  }

  cron { "rotate and process haproxy logs":
    command => "/srv/syslog/haproxy/processlog",
    user    => "root",
    hour    => 0, # avoid overlap with pgfouine
    minute  => 0,
    require => File["/srv/syslog/haproxy/processlog"],
  }

}
