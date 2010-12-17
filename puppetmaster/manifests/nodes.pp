node 'base-node' {

  include apt
  include puppet::client
  include c2corg::account
  include c2corg::mta
  include "c2corg::apt::$lsbdistcodename"
  include c2corg::common::packages
  include c2corg::common::services
  include c2corg::common::config

}

node 'pm' inherits 'base-node' {

  include puppet::server

  realize C2corg::Account::User[marc]
}

node 'lists' inherits 'base-node' {

}

node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

}

# ProLiant DL360 G4p - debian/squeeze
node 'hn0' inherits 'base-node' {

  include vz
  include c2corg::vz

  iptables { "setup nat for private LAN":
    table    => "nat",
    proto    => "all",
    chain    => "POSTROUTING",
    outiface => "eth2",
    source   => "192.168.192.0/24",
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

  iptables { "setup nat for VZ nodes":
    table    => "nat",
    proto    => "all",
    chain    => "POSTROUTING",
    outiface => "eth2",
    source   => "192.168.191.0/24",
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

  vz::fwd { "forward hn1 ssh port":
    net  => "192.168.192",
    ve   => "2",
    from => "20022",
    to   => "22",
  }

  vz::fwd { "forward hn2 ssh port":
    net  => "192.168.192",
    ve   => "3",
    from => "20023",
    to   => "22",
  }

  file { "/etc/network/if-pre-up.d/iptables":
    ensure  => present,
    mode    => 0755,
    content => "#!/bin/sh
# file managed by puppet

if [ -e /etc/iptables.rules ]; then
  /sbin/iptables-restore /etc/iptables.rules
fi
",
  }

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///c2corg/network/hn0",
  }

}

# ProLiant DL360 G4 - debian/kFreeBSD
node 'hn1' inherits 'base-node' {

  include puppet::devel
  include varnish

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///c2corg/network/hn1",
  }

  varnish::instance { $hostname:
    vcl_file   => "puppet:///c2corg/ha/c2corg.vcl",
    storage    => "malloc,7400M",
    varnishlog => false,
  }
}

# PowerEdge 2950 - debian/lenny
node 'hn2' inherits 'base-node' {

  include haproxy

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///c2corg/network/hn2",
  }

  augeas { "enable console on serial port":
    context => "/files/etc/inittab/T0/",
    changes => [
      "set runlevels 12345",
      "set action respawn",
      "set process '/sbin/getty -L ttyS0 115200 vt100'"
    ],
    notify  => Exec["refresh init"],
  }

}

node 'test-marc' inherits 'base-node' {

}

