define nat::setup($iface, $lan) {

  include nat

  iptables { $name:
    table    => "nat",
    proto    => "all",
    chain    => "POSTROUTING",
    outiface => $iface,
    source   => $lan,
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

}
