/* ProLiant DL360 G4p */
class c2cinfra::hn::hn0 inherits c2cinfra::hn {

  include hardware::raid::smartarray

  class { 'firewall': }

  nat::setup { "setup nat for private LAN":
    iface => "eth2",
    lan   => "192.168.192.0/24",
  }

  # apply all dynamically exported resources declared elsewhere
  Nat::Fwd <<| tag == 'portfwd' |>>

  file { '/etc/network/if-pre-up.d/iptables': ensure => absent }

}
