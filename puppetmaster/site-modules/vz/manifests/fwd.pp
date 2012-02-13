define vz::fwd ($net="192.168.192", $ve, $from, $to, $iface="eth2") {

  iptables { "forward from ${from} to ${net}.${ve}:${to}":
    chain       => "PREROUTING",
    table       => "nat",
    proto       => "tcp",
    iniface     => $iface,
    todest      => "${net}.${ve}:${to}",
    dport       => $from,
    jump        => "DNAT",
  }
}
