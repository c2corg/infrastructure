/* PowerEdge 1850 */
class c2corg::hn::hn5 inherits c2corg::hn {

  include hardware::raid::megaraid
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
    'forward hn5 ssh port':
      host => '6', from => '20026', to => '22',   tag => 'portfwd';
    'forward hn5 mosh port':
      host => '6', from => '6006',  to => '6006', tag => 'portfwd', proto => 'udp';
  }

}
