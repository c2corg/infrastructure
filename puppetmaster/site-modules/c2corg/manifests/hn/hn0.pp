/* ProLiant DL360 G4p */
class c2corg::hn::hn0 inherits c2corg::hn {

  include hardware::raid::smartarray

  iptables { "setup nat for private LAN":
    table    => "nat",
    proto    => "all",
    chain    => "POSTROUTING",
    outiface => "eth2",
    source   => "192.168.192.0/24",
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

  vz::fwd { "forward hn3 ssh port":
    net  => "192.168.192",
    ve   => "4",
    from => "20024",
    to   => "22",
  }

  vz::fwd { "forward hn4 ssh port":
    net  => "192.168.192",
    ve   => "5",
    from => "20025",
    to   => "22",
  }

  vz::fwd { "forward hn5 ssh port":
    net  => "192.168.192",
    ve   => "6",
    from => "20026",
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

  package { "netstat-nat": }

}
