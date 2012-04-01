define nat::fwd ($net="192.168.192", $host, $from, $to, $iface="eth2", $proto="tcp") {

  iptables { "forward from ${from} to ${net}.${host}:${to}":
    chain       => "PREROUTING",
    table       => "nat",
    proto       => $proto,
    iniface     => $iface,
    todest      => "${net}.${host}:${to}",
    dport       => $from,
    jump        => "DNAT",
  }

}
