class c2cinfra::vip {

  package { 'ucarp': ensure => present }

  include haproxy
  #include haproxy::collectd

  file { '/etc/network/vip-up.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

/sbin/ifup eth1:ucarp
',
  }
  file { '/etc/network/vip-down.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

/sbin/ifdown eth1:ucarp
',
  }
}
