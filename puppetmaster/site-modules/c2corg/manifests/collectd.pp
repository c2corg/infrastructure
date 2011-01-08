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

  $datadir = '/srv/collectd'

  resources { collectd_conf: purge => true; }

  file { $datadir:
    ensure => directory,
  }

  # TODO: tidy stall files in /srv/collectd

  Collectd::Rrdtool['rrd'] {
    datadir           => "\"${datadir}\"",
    cache_flush       => 900,
    cache_timeout     => 10,
    require           => File[$datadir],
  }

  Collectd::Network["network"] {
    listen => '"0.0.0.0" "25826"',
  }


  # visualisation stuff

  include thttpd

  file { "/var/www/cgi-bin/":
    ensure  => directory,
    require => Package["thttpd"],
  }

  package { 'drraw': require => Package['thttpd'] }

  line { "configure drraw rrd path":
    line    => "%datadirs = ( \"${datadir}\"  => \"[c2corg]\" );",
    file    => "/etc/drraw/drraw.conf",
    require => Package["drraw"],
  }

  file { "/var/www/cgi-bin/drraw.cgi":
    mode    => 0755,
    ensure  => directory,
    source  => "file:///usr/lib/cgi-bin/drraw/drraw.cgi",
    require => Package["drraw"],
  }

}
