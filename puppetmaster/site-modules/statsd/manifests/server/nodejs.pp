class statsd::server::nodejs {

  apt::pin { 'statsd_from_c2corg_repo':
    packages => 'statsd',
    label    => 'C2corg',
    priority => '1010',
  }

  apt::pin { 'nodejs_from_bpo':
    packages => 'nodejs',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

  package { 'statsd':
    ensure => present,
  } ->
  service { 'statsd':
    ensure    => stopped,
    enable    => false,
    hasstatus => false,
    pattern   => 'nodejs.*stats\.js.*/var/log/statsd/statsd.log',
  } ->
  runit::service { 'statsd':
    user    => '_statsd',
    group   => '_statsd',
    rundir  => '/var/run/statsd',
    logdir  => '/var/log/statsd',
    command => '/usr/bin/nodejs /usr/share/statsd/stats.js /etc/statsd/localConfig.js 2>&1',
  }

  # send data to riemman, which is configured to send them back to graphite.
  $riemann_host = hiera('riemann_host')
  file { '/etc/statsd/localConfig.js':
    ensure  => present,
    require => Package['statsd'],
    notify  => Runit::Service['statsd'],
    content => "// file managed by puppet
{
  graphitePort: 2003
, graphiteHost: \"${riemann_host}\"
, port: 8125
, flushInterval: 30000
}
",
  }

}
