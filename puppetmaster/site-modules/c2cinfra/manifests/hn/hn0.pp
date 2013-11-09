/* ProLiant DL360 G4p */
class c2cinfra::hn::hn0 inherits c2cinfra::hn {

  include hardware::raid::smartarray

  nat::setup { "setup nat for private LAN":
    iface => "eth2",
    lan   => "192.168.192.0/24",
  }

  # apply all dynamically exported resources declared elsewhere
  Nat::Fwd <<| tag == 'portfwd' |>>

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
