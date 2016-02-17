class c2cinfra::collectd::node {

  class {'collectd':
    interval => {
      'filecount' => '300',
      'df'        => '60',
      'lvm'       => '60',
      'md'        => '60',
      'entropy'   => '60',
      'ipmi'      => '60',
    },
  }

  collectd::config::global {
    'FQDNLookup':           value => 'false';
    'Hostname':             value => "${::hostname}";
    'WriteQueueLimitHigh':  value => '10000';
    'WriteQueueLimitLow':   value => '10000';
    'CollectInternalStats': value => 'true';
  }

  apt::pin { 'collectd_from_bpo_sloppy':
    packages => 'collectd collectd-core collectd-dbg collectd-dev collectd-utils libcollectdclient-dev libcollectdclient1',
    release  => "${::lsbdistcodename}-backports-sloppy",
    priority => '1010',
  }

  collectd::plugin { [
    'processes',
    'users',
  ]: }

  $included_classes = pdbquery('resources', ['and', ['=', ['node', 'name'], $::hostname], ['=', 'type', 'Class']])
  $apache_listen= pdbquery('resources', ['and', ['=', ['node', 'name'], $::hostname], ['=', 'type', 'Apache::Listen']])

  collectd::config::plugin { 'tcpconns plugin config':
    plugin   => 'tcpconns',
    settings => template('c2cinfra/collectd/tcpconns.erb'),
  }

  collectd::config::plugin { 'df plugin config':
    plugin   => 'df',
    settings => '
      FSType "tmpfs"
      FSType "bind"
      MountPoint "/dev"
      MountPoint "/dev/shm"
      MountPoint "/lib/init/rw"
      IgnoreSelected true
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
Attribute "duty" "<%= @duty %>"
Attribute "distro" "<%= @lsbdistcodename %>"
<% @role ||= "" -%>
<% @role.split(",").each do |r| -%>
Tag "<%= r %>"
<% end -%>
<Node riemann>
  Host "<%= scope.function_hiera(["riemann_host"]) %>"
  Protocol TCP
  TTLFactor 5.0
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
  Protocol \"tcp\"
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
      Interface "lo"
      Interface "br0"
      Interface "tun0"
      VerboseInterface "eth0"
      VerboseInterface "eth1"
      VerboseInterface "eth2"
      VerboseInterface "eth3"
',
    }
  }

  # additional plugins on hardware nodes
  if $::manufacturer or $::datacenter == 'gandi' {

    collectd::plugin { [
      'contextswitch',
      'entropy',
      'load',
      'lvm',
      'vmem',
    ]: }

    collectd::config::plugin { 'cpu plugin config':
      plugin   => 'cpu',
      settings => '
        ValuesPercentage true
        ReportByState true
        ReportByCpu false
',
    }

    collectd::config::plugin { 'memory plugin config':
      plugin   => 'memory',
      settings => '
        ValuesAbsolute   true
        ValuesPercentage true
',
    }

    collectd::config::plugin { 'swap plugin config':
      plugin   => 'swap',
      settings => '
        ReportBytes      true
        ValuesAbsolute   true
        ValuesPercentage true
',
    }

    collectd::config::plugin { 'disk plugin config':
      plugin   => 'disk',
      settings => '
        UdevNameAttr "DM_NAME"
',
    }

  }

  if (member(query_nodes('Service[ntp]'), $::fqdn)) {
    collectd::config::plugin { 'ntpd plugin config':
      plugin   => 'ntpd',
      settings => '
        ReverseLookups false
        IncludeUnitID true
',
    }
  }


  if ($::role !~ /lxc/) {
    # TODO: find a way to also run this plugin on LXC hosts
    collectd::config::plugin { 'monitor collectd itself':
      plugin   => 'processes',
      settings => 'ProcessMatch "collectd" "collectd.*/etc/collectd/collectd.conf"',
    }
  }

  if ($::virtual == 'lxc') {
    package { 'udev': ensure => purged }
  }

}
