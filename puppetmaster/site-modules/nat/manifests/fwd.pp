define nat::fwd ($net="192.168.192", $host, $from, $to, $proto, $iface="eth1") {

  firewall { "${name} (nat::fwd/from ${from}/${proto} to ${net}.${host}:${to})":
    chain       => "PREROUTING",
    table       => "nat",
    proto       => $proto,
    iniface     => $iface,
    todest      => "${net}.${host}:${to}",
    dport       => $from,
    jump        => "DNAT",
  }

}
