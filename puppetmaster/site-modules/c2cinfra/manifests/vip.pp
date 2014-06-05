class c2cinfra::vip {

  package { 'ucarp': ensure => present }

  include haproxy
  include haproxy::collectd

  file { '/etc/network/vip-up.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

( set -x
  /sbin/ip addr add 128.179.66.23/24 dev eth1:ucarp
  /sbin/ip ro add 128.179.66.0/24 dev eth1 src 128.179.66.23 table 66
  /sbin/ip ro add default via 128.179.66.1 table 66
  /sbin/ip rule add from 128.179.66.23 table 66
  /usr/sbin/arping -c 3 -B -S 128.179.66.23 -i eth1
) 2>&1 | logger -t vip-up
',
  }
  file { '/etc/network/vip-down.sh':
    ensure  => present,
    mode    => 0755,
    require => Package['ucarp'],
    content => '#!/bin/sh
# file managed by puppet

( set -x
  /sbin/ip rule del from 128.179.66.23 table 66
  /sbin/ip addr del 128.179.66.23/24 dev eth1:ucarp
) 2>&1 | logger -t vip-down
',
  }
}
