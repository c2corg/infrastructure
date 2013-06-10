/* PowerEdge 2950 */
class c2cinfra::hn::hn2 inherits c2cinfra::hn {

  include hardware::raid::megaraidsas
  include ipmi

  augeas { 'enable console on serial port':
    changes => [
      'set T0/runlevels 12345',
      'set T0/action respawn',
      "set T0/process '/sbin/getty -L ttyS1 57600 vt100'"
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
      value => "\"console=tty1 console=ttyS1,57600n8\"";
    'grub terminal':
      key   => 'GRUB_TERMINAL',
      value => 'serial';
    'grub serial command':
      key   => 'GRUB_SERIAL_COMMAND',
      value => "\"serial --speed=57600 --unit=0 --word=8 --parity=no --stop=1\"";
  }

}
