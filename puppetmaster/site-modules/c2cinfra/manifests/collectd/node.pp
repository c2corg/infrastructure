class c2cinfra::collectd::node {

  class {'collectd':
    interval => {
      'filecount' => '300',
      'df'        => '60',
      'lvm'       => '60',
      'entropy'   => '60',
      'ipmi'      => '60',
    },
  }

  collectd::config::global {
    'FQDNLookup': value => 'false';
    'Hostname':   value => "${::hostname}";
  }

  apt::pin { 'collectd_from_c2corg':
    packages => 'collectd collectd-core collectd-dbg collectd-dev collectd-utils libcollectdclient-dev libcollectdclient1',
    label    => 'C2corg',
    release  =>  "${::lsbdistcodename}",
    priority => '1010',
  }

  collectd::plugin { [
    'processes',
    'protocols',
    'tcpconns',
    'users',
  ]: }

  collectd::config::plugin { 'df plugin config':
    plugin   => 'df',
    settings => '
      FSType "tmpfs"
      FSType "bind"
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
SocketFile "/var/run/collectd-unixsock"
SocketGroup "root"
DeleteSocket true
',
  }

  collectd::config::plugin { 'send metrics to riemann':
    plugin   => 'write_riemann',
    settings => inline_template('
Tag collectd
Tag "<%= @duty %>"
Tag "<%= @lsbdistcodename %>"
Tag "puppet_config_version:<%= scope.catalog.version %>"
<% @role ||= "" -%>
<% @role.split(",").each do |r| -%>
Tag "<%= r %>"
<% end -%>
<Node riemann>
  Host "<%= scope.function_hiera("riemann_host") %>"
  AlwaysAppendDS true
</Node>
'),
  }

  $carbon_host = hiera('carbon_host')

  collectd::config::plugin { 'send metrics to carbon':
    plugin   => 'write_graphite',
    settings => "
<Node carbon>
  Host \"${carbon_host}\"
  Port \"2003\"
  Protocol \"udp\"
  Prefix \"collectd.\"
</Node>
",
  }

  if $::lsbdistcodename == 'squeeze' {
    collectd::plugin { 'interface': }
  } else {
    collectd::config::plugin { 'setup netlink plugin':
      plugin   => 'netlink',
      settings => '
VerboseInterface "All"
',
    }
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
      'lvm',
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
