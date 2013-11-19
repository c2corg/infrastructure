class statsd::server::nodejs {

  apt::pin { 'statsd_from_c2corg_repo':
    packages => 'statsd nodejs',
    label    => 'C2corg',
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

}
