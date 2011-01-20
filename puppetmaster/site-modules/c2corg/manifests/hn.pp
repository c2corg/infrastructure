class c2corg::hn {

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///c2corg/network/${hostname}",
  }

  collectd::plugin { ['cpu', 'df', 'disk', 'entropy', 'irq', 'swap']: }

}

/* openvz host */
class c2corg::hn::hn0 inherits c2corg::hn {

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

}

/* varnish server */
class c2corg::hn::hn1 inherits c2corg::hn {
}

/* webserver & database */
class c2corg::hn::hn2 inherits c2corg::hn {

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
