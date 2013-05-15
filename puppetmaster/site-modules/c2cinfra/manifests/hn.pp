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

  package { ['iozone3', 'setserial']: }

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

  exec { 'update-grub':
    refreshonly => true,
  }

}
