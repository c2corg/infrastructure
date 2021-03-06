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

  if $::processor0 =~ /(I|i)ntel/ {
    include '::hardware::intel'
  }

  file { "/etc/network/interfaces":
    ensure => present,
    source => "puppet:///modules/c2cinfra/network/${::hostname}",
  }

  package { ['iozone3', 'setserial']: }

  package { ['hdparm', 'lvm2', 'memtest86+', 'smartmontools']: }

  package { 'lldpd':
    ensure => present,
  }

  service { 'lldpd':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => Package['lldpd'],
  }

  # kernel must reboot if panic occurs
  sysctl::value { "kernel.panic": value => "60" }

  if $::datacenter =~ /c2corg|epnet|pse/ {
    # disable tcp_sack due to Cisco bug in epnet routers
    sysctl::value { "net.ipv4.tcp_sack": value => "0" }
  }

  exec { 'update-grub':
    refreshonly => true,
  }

  if ($::lsbdistcodename == 'wheezy') {
    package { ['firmware-linux', 'firmware-bnx2']: ensure => present }
  }

}
