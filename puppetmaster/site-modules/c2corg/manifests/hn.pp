class c2corg::hn {

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///modules/c2corg/network/${::hostname}",
  }

  $collectdplugins = $::operatingsystem ? {
    'GNU/kFreeBSD' => ['cpu', 'df', 'swap'],
    default        => ['cpu', 'df', 'disk', 'entropy', 'irq', 'swap'],
  }
  collectd::plugin { $collectdplugins: lines => [] }

  package { "iozone3": }

  if ($::operatingsystem != 'GNU/kFreeBSD') {
    package { ["hdparm", "xfsprogs"]: }
  }

}
