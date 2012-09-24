/* ProLiant DL360 G4p */
class c2corg::hn::hn0 inherits c2corg::hn {

  include hardware::raid::smartarray

  nat::setup { "setup nat for private LAN":
    iface => "eth2",
    lan   => "192.168.192.0/24",
  }

  Nat::Fwd {
    net => '192.168.192',
  }

  nat::fwd {
    'forward hn1 ssh port':
      host => '2', from => '20022', to => '22';
    'forward hn1 mosh port':
      host => '2', from => '6002',  to => '6002', proto => 'udp';
  }

  nat::fwd {
    'forward hn2 ssh port':
      host => '3', from => '20023', to => '22';
    'forward hn2 mosh port':
      host => '3', from => '6003',  to => '6003', proto => 'udp';
  }

  nat::fwd {
    'forward hn3 ssh port':
      host => '4', from => '20024', to => '22';
    'forward hn3 mosh port':
      host => '4', from => '6004',  to => '6004', proto => 'udp';
  }

  nat::fwd {
    'forward hn4 ssh port':
      host => '5', from => '20025', to => '22';
    'forward hn4 mosh port':
      host => '5', from => '6005',  to => '6005', proto => 'udp';
  }

  nat::fwd {
    'forward hn5 ssh port':
      host => '6', from => '20026', to => '22';
    'forward hn5 mosh port':
      host => '6', from => '6006',  to => '6006', proto => 'udp';
  }

  nat::fwd {
    'forward hn6 ssh port':
      host => '7', from => '20027', to => '22';
    'forward hn6 mosh port':
      host => '7', from => '6007',  to => '6007', proto => 'udp';
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
