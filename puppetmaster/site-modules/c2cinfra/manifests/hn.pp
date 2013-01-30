class c2cinfra::hn {

  include ipmi::client

  case $::manufacturer {
    /Dell/: {
      include hardware::omsa
    }
    /IBM/: {
    }
    /HP/: {
    }
  }

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///modules/c2cinfra/network/${::hostname}",
  }

  collectd::plugin { ['cpu', 'disk', 'entropy', 'irq', 'swap']: }

  collectd::config::plugin { 'df plugin config':
    plugin   => 'df',
    settings => '
      MountPoint "/dev"
      MountPoint "/dev/shm"
      MountPoint "/lib/init/rw"
      IgnoreSelected true
      ReportReserved true
      ReportInodes true
',
  }

  package { "iozone3": }

  package { ["hdparm", "xfsprogs", "lvm2"]: }

  package { 'lldpd':
    ensure => present,
  }

  service { 'lldpd':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => Package['lldpd'],
  }

}
