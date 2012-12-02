/* PowerEdge 1850 */
class c2cinfra::hn::hn6 inherits c2cinfra::hn {

  include hardware::raid::md
  include ipmi

  augeas { 'enable console on serial port':
    changes => [
      'set T0/runlevels 12345',
      'set T0/action respawn',
      "set T0/process '/sbin/getty -L ttyS0 115200 vt100'"
    ],
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    notify  => Exec['refresh init'],
  }

  @@nat::fwd {
    'forward hn6 ssh port':
      host => '7', from => '20027', to => '22',   tag => 'portfwd', proto => 'tcp';
    'forward hn6 mosh port':
      host => '7', from => '6007',  to => '6007', tag => 'portfwd', proto => 'udp';
  }

}
