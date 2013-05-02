class graphite::carbon {

  if (versioncmp($::operatingsystemrelease, 7) < 0) {
    fail('unsupported system')
  }

  include '::runit'

  package { ['python-whisper', 'graphite-carbon']:
    ensure => present
  } ->

  etcdefault { 'prevent carbon from getting started by sysvinit':
    file  => 'graphite-carbon',
    key   => 'CARBON_CACHE_ENABLED',
    value => 'false',
  } ->

  file { '/etc/carbon/storage-schemas.conf':
    notify  => Runit::Service['carbon-cache'],
    content => '# file managed by puppet
[carbon]
pattern = ^carbon\.
retentions = 60:90d

[default_1min_for_1day]
pattern = .*
retentions = 15s:7d,1m:21d,15m:5y
',
  } ->

  augeas { 'carbon-cache configuration':
    incl    => '/etc/carbon/carbon.conf',
    lens    => 'Carbon.lns',
    changes => [
      'set cache/MAX_UPDATES_PER_SECOND 100',
      'set cache/MAX_CREATES_PER_MINUTE 25',
      'set cache/WHISPER_AUTOFLUSH True',
    ],
  } ~>

  runit::service { 'carbon-cache':
    user    => '_graphite',
    group   => '_graphite',
    rundir  => '/var/lib/graphite',
    command => '/usr/bin/carbon-cache --debug --pidfile=carbon-cache.pid --config=/etc/carbon/carbon.conf start',
  }

}
