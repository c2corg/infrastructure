class c2corg::collectd::client {
  include collectd

  collectd::conf {
    'FQDNLookup':
      value => 'false';
    'TypesDB':
      value => '/usr/share/collectd/types.db', quote => true;
    'LoadPlugin':
      value => $operatingsystem ? {
        'GNU/kFreeBSD' => ['interface', 'load', 'memory', 'users'],
        default        => ['contextswitch', 'exec', 'interface', 'load', 'memory', 'processes', 'tcpconns', 'users', 'vmem']
      };
  }

  file { "/var/lib/collectd/rrd/":
    ensure  => absent,
    recurse => true,
    force   => true,
    notify  => Service["collectd"],
  }

  collectd::network { 'network':
    server      => $datacenter ? {
      /c2corg|epnet|pse/ => '192.168.192.126',
      default            => '128.179.66.13',
    },
    cache_flush => 86400,
  }

  collectd::syslog { 'info': }

  if $operatingsystem != 'GNU/kFreeBSD' {
    package { 'udev': } # else collectd installation fails on VZs.
  }

}
