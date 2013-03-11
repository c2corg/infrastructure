class c2cinfra::vip {

  package { 'ucarp': ensure => present }

  $varnish_host          = hiera('varnish_host')
  $symfony_master_host   = hiera('symfony_master_host')
  $symfony_failover_host = hiera('symfony_failover_host')

  include haproxy
  include haproxy::collectd

  file { '/etc/network/vip-up.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

/sbin/ifup eth0:ucarp
',
  }
  file { '/etc/network/vip-down.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

/sbin/ifdown eth0:ucarp
',
  }
}
