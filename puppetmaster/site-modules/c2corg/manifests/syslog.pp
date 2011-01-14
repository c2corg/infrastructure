class c2corg::syslog::client {

  $syslog_server = "192.168.191.126"

  package { "syslog":
    name   => "rsyslog",
    ensure => present,
  }

  service { "syslog":
    name    => "rsyslog",
    ensure  => running, enable => true, hasstatus => true,
    require => Package["syslog"],
  }

  file { "local syslog config":
    path    => "/etc/rsyslog.d/remotelogs.conf",
    ensure  => present,
    content => inline_template('# file managed by puppet
<% if operatingsystem != "lenny" -%>
$MaxMessageSize 64k
<% end -%>
*.*    @@<%= syslog_server %>
'),
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

}

class c2corg::syslog::server inherits c2corg::syslog::client {

  Package["syslog"] { name => "syslog-ng" }
  Service["syslog"] { name => "syslog-ng", hasstatus => false }

  File["local syslog config"] {
    path    => "/etc/syslog-ng/local.conf",
    content => "# file managed by puppet
source s_remote {
  tcp(log_msg_size(65536));
};

destination d_hosts {
  file('/srv/syslog/logs/\$HOST/\$FACILITY.log'
    dir_perm(0755)
    create_dirs(yes)
  );
};

destination d_postgresql_prod {
  file('/srv/syslog/postgresql/prod.log');
};

filter f_postgresql_prod {
  program('postgres') and
  host('192.168.192.3');
};

log {
  source(s_remote);
  filter(f_postgresql_prod);
  destination(d_postgresql_prod);
  flags(final);
};

log {
  source(s_remote);
  source(s_src);
  destination(d_hosts);
};

",
  }

  augeas { "disable syslog-ng capabilies since they are unavailable inside vz nodes":
    changes => "set /files/etc/default/syslog-ng/SYSLOGNG_OPTS --no-caps",
  }

  line { "include local syslog config":
    file    => "/etc/syslog-ng/syslog-ng.conf",
    line    => 'include "/etc/syslog-ng/local.conf";',
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

  file { ["/srv/syslog", "/srv/syslog/postgresql"]: ensure => directory }

  augeas { "logrotate syslog-ng files":
    context => "/files/etc/logrotate.d/srv-syslog/rule",
    changes => [
      "set file /srv/syslog/logs/*/*.log",
      "set schedule weekly",
      "set rotate 52",
      "set compress compress",
      "set missingok missingok",
      "set postrotate '/usr/sbin/invoke-rc.d syslog-ng reload >/dev/null'",
    ],
  }

}

class c2corg::syslog::pgfouine {

  package { ["pgfouine"]: ensure => present }

  $pgfouinemem = "2048M"

  # TODO: tidy this directory from old reports
  file { "/var/www/pgfouine": ensure => directory }

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
    /usr/bin/pgfouine -file /srv/syslog/postgresql/prod.log.1 -top 30 -format html -memorylimit ${pgfouinemem} -report /var/www/pgfouine/$(date +%Y%m%d-%Hh%Mm).html=overall,hourly,bytype,slowest,n-mosttime,n-mostfrequent,n-slowestaverage,n-mostfrequenterrors 2>&1 | logger -t pgfouine
  endscript
}
",
  }

  augeas { "increase php-cli memory limit for pgfouine":
    changes => "set /files/etc/php5/cli/php.ini/PHP/memory_limit ${pgfouinemem}",
  }

  augeas { "prevent suhosin from loading":
    changes => "rm /files/etc/php5/conf.d/suhosin.ini/.anon/extension",
  }

  cron { "rotate and process postgresql logs":
    command => "/srv/syslog/postgresql/processlog",
    user    => "root",
    hour    => "*/6",
    minute  => "0",
    require => File["/srv/syslog/postgresql/processlog"],
  }

}

