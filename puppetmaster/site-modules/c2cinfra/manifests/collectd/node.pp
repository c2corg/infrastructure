class c2cinfra::collectd::node {

  class {'collectd':
    interval => {
      'filecount' => '300',
      'df'        => '60',
      'lvm'       => '60',
      'entropy'   => '60',
    },
  }
  include haproxy::collectd::typesdb

  $collectd_host = hiera('collectd_host')

  collectd::config::global {
    'FQDNLookup': value => 'false';
  }

  apt::preferences { 'collectd_from_c2corg':
    package  => 'collectd collectd-core collectd-dbg collectd-dev collectd-utils libcollectdclient-dev libcollectdclient1',
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => '1010',
  }

  collectd::plugin { [
    'interface',
    'processes',
    'protocols',
    'tcpconns',
    'users',
  ]: }

  collectd::config::plugin { 'setup network plugin':
    plugin   => 'network',
    settings => inline_template('
Server     "<%= collectd_host %>"
ReportStats true
'),
  }

  collectd::config::plugin { 'df plugin config':
    plugin   => 'df',
    settings => '
      FSType "tmpfs"
      MountPoint "/dev"
      MountPoint "/dev/shm"
      MountPoint "/lib/init/rw"
      IgnoreSelected true
      ReportReserved true
      ReportInodes true
      ValuesAbsolute true
      ValuesPercentage true
',
  }

  collectd::config::plugin { 'setup unixsock plugin':
    plugin   => 'unixsock',
    settings => '
SocketFile "/var/run/collectd.sock"
SocketGroup "root"
DeleteSocket true
',
  }

  # additional plugins on hardware nodes
  if $::manufacturer or $::datacenter == 'gandi' {

    collectd::plugin { [
      'cpu',
      'contextswitch',
      'disk',
      'entropy',
      'irq',
      'load',
      'memory',
      'swap',
      'vmem',
    ]: }
  }

  # TODO: find a way to also run this plugin on LXC hosts
  if (!$::lxc_type) or ($::lxc_type == 'container') {
    collectd::config::plugin { 'monitor collectd itself':
      plugin   => 'processes',
      settings => 'ProcessMatch "collectd" "collectd.*/etc/collectd/collectd.conf"',
    }
  }

  if $::lxc_type == 'container' {
    package { 'udev': ensure => purged }
  }

}
