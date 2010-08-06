node 'base-node' {

  include "os::$lsbdistcodename"
  include apt
  include puppet::client
  include account

}

node 'pm' inherits 'base-node' {

  include puppet::server

  realize Account::User[marc]
}

node 'hn0' inherits 'base-node' {

  include vz

  iptables { "setup nat for private LAN":
    table    => "nat",
    chain    => "POSTROUTING",
    outiface => "eth2",
    source   => "192.168.192.0/24",
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

  iptables { "setup nat for VZ nodes":
    table    => "nat",
    chain    => "POSTROUTING",
    outiface => "eth2",
    source   => "192.168.191.0/24",
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

  vz::ve { "101": hname => "pm.c2corg" }
}

