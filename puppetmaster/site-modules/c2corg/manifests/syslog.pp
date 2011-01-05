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
    content => "# file managed by puppet\n*.*    @${syslog_server}\n",
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
  udp();
};

destination d_hosts {
  file('/srv/syslog/\$HOST/\$FACILITY.log'
    dir_perm(0755)
    create_dirs(yes)
  );
};

log {
  source(s_remote);
  source(s_src);
  destination(d_hosts);
};

",
  }

  line { "include local syslog config":
    file    => "/etc/syslog-ng/syslog-ng.conf",
    line    => 'include "/etc/syslog-ng/local.conf";',
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

  file { ["/srv/syslog"]:
    ensure => directory,
  }

  augeas { "logrotate syslog-ng files":
    context => "/files/etc/logrotate.d/srv-syslog/rule",
    changes => [
      "set file /srv/syslog/*/*.log",
      "set schedule weekly",
      "set rotate 52",
      "set compress compress",
      "set missingok missingok",
    ],
  }

}

