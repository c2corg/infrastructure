class c2cinfra::collectd::node {

  include collectd
  include haproxy::collectd::typesdb

  $collectd_host = hiera('collectd_host')

  collectd::config::global {
    'FQDNLookup': value => 'false';
  }

  if $::lsbdistcodename == 'squeeze' {
    apt::preferences { 'collectd_from_bpo':
      package  => 'collectd collectd-core collectd-dbg collectd-dev collectd-utils libcollectdclient-dev libcollectdclient0',
      pin      => "release a=${::lsbdistcodename}-backports",
      priority => '1010',
    }
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
