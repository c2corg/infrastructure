class lxc::guest {

# TODO:
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

  # TODO: augeasify this resource
  exec { 'deactivate klogd in containers':
    command => 'sed -i -r "s/^(.+imklog.*)/#\1/" /etc/rsyslog.conf',
    onlyif  => 'grep -Eq \'^\$ModLoad\s+imklog\' /etc/rsyslog.conf',
    notify  => Service['syslog'],
  }
}
