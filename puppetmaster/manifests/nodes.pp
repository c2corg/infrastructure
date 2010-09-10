node 'base-node' {

  include "os::$lsbdistcodename"
  include apt
  include puppet::client
  include account
  include mta

}

node 'pm' inherits 'base-node' {

  include puppet::server

  realize Account::User[marc]
}

node 'lists' inherits 'base-node' {

}

node 'hn0' inherits 'base-node' {

  include vz

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


  /* puppetmaster */

  vz::ve { "101": hname => "pm.c2corg" }

  vz::fwd { "forward puppetmaster port":
    ve   => "101",
    from => "8140",
    to   => "8140",
  }
  vz::fwd { "forward puppetmaster ssh port":
    ve   => "101",
    from => "10122",
    to   => "22",
  }

  /* mailing-lists */

  vz::ve { "102": hname => "lists.c2corg" }

  vz::fwd { "forward smtp port":
    ve   => "102",
    from => "25",
    to   => "25",
  }
  vz::fwd { "forward lists ssh port":
    ve   => "102",
    from => "10222",
    to   => "22",
  }

}

node 'hn1' inherits 'base-node' {

  include puppet::devel
  include varnish
}

