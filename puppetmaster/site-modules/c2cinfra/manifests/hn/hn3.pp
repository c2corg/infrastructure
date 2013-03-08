/* System x3550 M3 */
class c2cinfra::hn::hn3 inherits c2cinfra::hn {

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

  Etcdefault {
    file   => 'grub',
    notify => Exec['update-grub'],
  }

  etcdefault {
    'grub cmdline':
      key   => 'GRUB_CMDLINE_LINUX',
      value => "\"console=tty1 console=ttyS0,115200n8\"";
    'grub terminal':
      key   => 'GRUB_TERMINAL',
      value => 'serial';
    'grub serial command':
      key   => 'GRUB_SERIAL_COMMAND',
      value => "\"serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\"";
  }

  @@nat::fwd {
    'forward hn3 ssh port':
      host => '4', from => '20024', to => '22',   tag => 'portfwd', proto => 'tcp';
    'forward hn3 mosh port':
      host => '4', from => '6004',  to => '6004', tag => 'portfwd', proto => 'udp';
  }

}
