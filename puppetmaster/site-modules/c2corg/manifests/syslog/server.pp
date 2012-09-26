class c2corg::syslog::server inherits c2corg::syslog::client {

  Package["syslog"] { name => "syslog-ng" }
  Service["syslog"] { name => "syslog-ng", hasstatus => false }

  package { "petit": ensure => present }

  File["local syslog config"] {
    path    => "/etc/syslog-ng/local.conf",
    content => "# file managed by puppet
source s_remote {
  tcp(log_msg_size(65536) max-connections(50));
};

destination d_hosts {
  file('/srv/syslog/logs/\$HOST/\$FACILITY.log'
    dir_perm(0755)
    create_dirs(yes)
  );
};

# PostgreSQL production logs

destination d_postgresql_prod {
  file('/srv/syslog/postgresql/prod.log');
};

filter f_postgresql_prod {
  program('postgres') and
  host('192.168.192.5');
};

log {
  source(s_remote);
  filter(f_postgresql_prod);
  destination(d_postgresql_prod);
  flags(final);
};

# HAProxy production logs

destination d_haproxy_prod {
  file('/srv/syslog/haproxy/prod.log');
};

filter f_haproxy_prod {
  program('haproxy') and
  host('192.168.192.4');
};

log {
  source(s_remote);
  filter(f_haproxy_prod);
  destination(d_haproxy_prod);
  flags(final);
};

# Default logs

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

  file_line { "include local syslog config":
    path    => "/etc/syslog-ng/syslog-ng.conf",
    line    => 'include "/etc/syslog-ng/local.conf";',
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

  file { ["/srv/syslog", "/srv/syslog/postgresql", "/srv/syslog/haproxy"]: ensure => directory }

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
