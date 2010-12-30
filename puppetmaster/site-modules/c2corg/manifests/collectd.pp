class c2corg::collectd::client {
  include collectd

  collectd::conf {
    'FQDNLookup':
      value => 'false';
    'LoadPlugin':
      value => $operatingsystem ? {
        'GNU/kFreeBSD' => ['interface', 'load', 'memory', 'processes', 'users'],
        default        => ['interface', 'load', 'memory', 'processes', 'users', 'vmem']
      };
  }

  collectd::rrdtool { 'rrd': }

  collectd::network { 'network':
    server      => '192.168.191.126',
    cache_flush => 86400,
  }

  collectd::syslog { 'info': }

  if $lsbdistcodename == 'lenny' {
    apt::preferences { ['collectd', 'collectd-utils']:
      pin      => 'release a=lenny-backports',
      priority => '1010',
    }
  }

  if $operatingsystem != 'GNU/kFreeBSD' {
    package { 'udev': } # else collectd installation fails on VZs.
  }

}

class c2corg::collectd::server inherits c2corg::collectd::client {

  resources { collectd_conf: purge => true; }

  file { '/srv/collectd':
    ensure => directory,
  }

  # TODO: tidy stall files in /srv/collectd

  Collectd::Rrdtool['rrd'] {
    datadir           => '"/srv/collectd"',
    cache_flush       => 900,
    cache_timeout     => 10,
    require           => File['/srv/collectd'],
  }

  Collectd::Network["network"] {
    listen => '"0.0.0.0" "25826"',
  }


  # visualisation stuff

  include thttpd
  package { 'drraw': require => Package['thttpd'] }

}
