/* ProLiant DL360 G4p */
class c2corg::hn::hn0 inherits c2corg::hn {

  include hardware::raid::smartarray

  nat::setup { "setup nat for private LAN":
    iface => "eth2",
    lan   => "192.168.192.0/24",
  }

  nat::fwd { "forward hn1 ssh port":
    net  => "192.168.192",
    host => "2",
    from => "20022",
    to   => "22",
  }

  nat::fwd { "forward hn2 ssh port":
    net  => "192.168.192",
    host => "3",
    from => "20023",
    to   => "22",
  }

  nat::fwd { "forward hn3 ssh port":
    net  => "192.168.192",
    host => "4",
    from => "20024",
    to   => "22",
  }

  nat::fwd { "forward hn4 ssh port":
    net  => "192.168.192",
    host => "5",
    from => "20025",
    to   => "22",
  }

  nat::fwd { "forward hn5 ssh port":
    net  => "192.168.192",
    host => "6",
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

}
