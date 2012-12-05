class c2cinfra::hn {

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///modules/c2cinfra/network/${::hostname}",
  }

  $collectdplugins = $::operatingsystem ? {
    'GNU/kFreeBSD' => ['cpu', 'swap'],
    default        => ['cpu', 'disk', 'entropy', 'irq', 'swap'],
  }
  collectd::plugin { $collectdplugins: lines => [] }

  collectd::plugin { 'df':
    lines => [
      'MountPoint "/dev"',
      'MountPoint "/dev/shm"',
      'MountPoint "/lib/init/rw"',
      'IgnoreSelected true',
      'ReportReserved true',
      'ReportInodes true',
    ],
  }

  package { "iozone3": }

  if ($::operatingsystem != 'GNU/kFreeBSD') {
    package { ["hdparm", "xfsprogs", "lvm2"]: }
  }

  package { 'lldpd':
    ensure => present,
  }

  service { 'lldpd':
    ensure  => running,
    enable  => true,
    require => Package['lldpd'],
  }

}
