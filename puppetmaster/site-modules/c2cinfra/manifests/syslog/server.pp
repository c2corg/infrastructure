class c2cinfra::syslog::server inherits c2cinfra::syslog::client {

  Package["syslog"] { name => "syslog-ng" }
  Service["syslog"] { name => "syslog-ng", hasstatus => false }

  package { "petit": ensure => present }

  $db_host = hiera('db_host')

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

# HAProxy production logs

destination d_haproxy_prod {
  file('/srv/syslog/haproxy/prod.log');
};

filter f_haproxy_prod {
  program('haproxy');
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

  etcdefault { 'disable syslog-ng capabilies since they are unavailable inside vz nodes':
    key   => 'SYSLOGNG_OPTS',
    file  => 'syslog-ng',
    value => '--no-caps',
  }

  file_line { "include local syslog config":
    path    => "/etc/syslog-ng/syslog-ng.conf",
    line    => 'include "/etc/syslog-ng/local.conf";',
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

  file { ["/srv/syslog", "/srv/syslog/haproxy"]: ensure => directory }

  augeas { "logrotate syslog-ng files":
    incl    => '/etc/logrotate.d/srv-syslog',
    lens    => 'Logrotate.lns',
    changes => [
      "set rule/file /srv/syslog/logs/*/*.log",
      "set rule/schedule weekly",
      "set rule/rotate 52",
      "set rule/compress compress",
      "set rule/missingok missingok",
      "set rule/postrotate '/usr/sbin/invoke-rc.d syslog-ng reload >/dev/null'",
    ],
  }

}
