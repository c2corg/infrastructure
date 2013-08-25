class c2cinfra::openvpn {

  package { 'openvpn': ensure => present } ->

  etcdefault { 'enable vpns at boot':
    key   => 'AUTOSTART',
    file  => 'openvpn',
    value => 'c2corg',
  } ->

  service { 'openvpn':
    ensure    => running,
    hasstatus => true,
    enable    => true,
  }

  collectd::config::plugin { 'openvpn status file':
    plugin   => 'openvpn',
    settings => '
  StatusFile "/var/run/openvpn-status.log"
  ImprovedNamingSchema "true"
',
  }

}
