/* System x3550 M3 */
class c2corg::hn::hn3 inherits c2corg::hn {

  include hardware::raid::megaraidsas
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
    'forward hn3 ssh port':
      host => '4', from => '20024', to => '22',   tag => 'portfwd', proto => 'tcp';
    'forward hn3 mosh port':
      host => '4', from => '6004',  to => '6004', tag => 'portfwd', proto => 'udp';
  }

}
