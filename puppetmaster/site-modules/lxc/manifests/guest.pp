class lxc::guest {

# TODO:
# syslog: disable kernel logging
# network config
# root password policy
# disable hwclock access

  augeas { 'configure reboot in inittab':
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    notify  => Exec['refresh init'],
    changes => [
      'set rb/runlevels ""',
      'set rb/action ctrlaltdel',
      'set rb/process /sbin/reboot',
    ],
  }

  augeas { 'configure shutdown in inittab':
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    notify  => Exec['refresh init'],
    changes => [
      'set po/runlevels ""',
      'set po/action powerwait',
      'set po/process /sbin/halt',
    ],
  }

  augeas { 'disable inittab respawn to sulogin':
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    changes => "rm *[action='respawn'][process='/sbin/sulogin']",
    notify  => Exec['refresh init'],
  }

}
