class c2cinfra::collectd::node {

  include collectd
  include haproxy::collectd::typesdb

  $collectd_host = hiera('collectd_host')

  collectd::config::global {
    'FQDNLookup': value => 'false';
    'TypesDB':    value => '/usr/share/collectd/types.db';
  }

  collectd::plugin { [
    'contextswitch',
    'exec',
    'interface',
    'load',
    'memory',
    'processes',
    'tcpconns',
    'users',
    'vmem']: }

  collectd::config::plugin { 'setup network plugin':
    plugin   => 'network',
    settings => inline_template('
Server     "<%= collectd_host %>"
CacheFlush 86400
'),
  }

  collectd::config::plugin { 'setup syslog plugin':
    plugin   => 'syslog',
    settings => 'LogLevel info',
  }

  package { 'udev': } # else collectd installation fails on VZs.

  file { '/var/lib/puppet/modules/':
    ensure  => absent,
    purge   => true,
    force   => true,
    recurse => true,
  }

}
