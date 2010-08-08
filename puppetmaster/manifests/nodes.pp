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

