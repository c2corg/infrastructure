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

  # workaround disfunctional dependency-based boot wrt/ filesystem mounting
  # inside containers
  file { '/etc/init.d/lxc-mountall.sh':
    source => 'puppet:///modules/lxc/lxc-mountall.sh',
    ensure => present,
    mode   => '0755',
  } ->
  service { 'lxc-mountall.sh':
    ensure => undef,
    enable => true,
  }
}
