class unbound {

  package { "unbound": ensure => present }

  exec { "unbound-control-setup":
    require => Package["unbound"],
    creates => [
      "/etc/unbound/unbound_control.pem",
      "/etc/unbound/unbound_server.pem",
    ]
  }

  exec { "fetch named.cache":
    command => "curl -s ftp://FTP.INTERNIC.NET/domain/named.cache > /etc/unbound/named.cache",
    creates => "/etc/unbound/named.cache",
    require => [Package["curl"], Package["unbound"]],
    notify  => Service["unbound"],
  }

  service { "unbound":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/sbin/unbound",
    require   => Package["unbound"],
  }

  augeas { "enable unbound":
    changes => "set /files/etc/default/unbound/UNBOUND_ENABLE true",
    require => Package["unbound"],
    before  => Service["unbound"],
  }

  file { "/etc/unbound/unbound.conf":
    content => '# file managed by puppet
server:
  verbosity: 1
  statistics-cumulative: yes
  extended-statistics: yes
  interface: 0.0.0.0
  access-control: 192.168.0.0/16 allow
  chroot: ""
  root-hints: "/etc/unbound/named.cache"
  private-domain: "infra.camptocamp.org"
remote-control:
  control-enable: yes
  control-interface: 127.0.0.1
  control-port: 953
',
    notify  => Service["unbound"],
    require => Package["unbound"],
  }
}
