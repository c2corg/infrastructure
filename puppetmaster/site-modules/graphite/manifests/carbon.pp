class graphite::carbon {

  if (versioncmp($::operatingsystemrelease, 7) < 0) {
    fail('unsupported system')
  }

  include '::graphite'
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

[statsd]
pattern = ^(stats|stats_counts)\.
retentions = 30s:1d,2m:7d,10m:21d,30m:2y
xFilesFactor = 0.0

[collectd_policy_lvm]
pattern = ^collectd\..*\.lvm-.*
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_md]
pattern = ^collectd\..*\.md-.*
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_df]
pattern = ^collectd\..*\.df-.*
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_entropy]
pattern = ^collectd\..*\.entropy
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_ipmi]
pattern = ^collectd\..*\.ipmi
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_uptime]
pattern = ^collectd\..*\.uptime
retentions = 30s:1d,2m:7d,10m:21d,30m:5y

[collectd_policy_filecount]
pattern = ^collectd\..*\.filecount-.*
retentions = 5m:1d,15m:7d,60m:5y

[collectd_policy]
pattern = ^collectd\.
retentions = 10s:1d,30s:7d,1m:21d,15m:5y

[puppet_reports_policy]
pattern = ^puppet_reports\.
retentions = 60m:5y

[default_local_setting]
pattern = .*
retentions = 15s:7d,1m:21d,15m:5y
',
  } ->

  augeas { 'carbon-cache configuration':
    incl    => '/etc/carbon/carbon.conf',
    lens    => 'Carbon.lns',
    changes => [
      'set cache/MAX_UPDATES_PER_SECOND 100',
      'set cache/MAX_UPDATES_PER_SECOND_ON_SHUTDOWN 250',
      'set cache/MAX_CREATES_PER_MINUTE 25',
      'set cache/WHISPER_AUTOFLUSH True',
      'set cache/ENABLE_UDP_LISTENER True',
    ],
  } ~>

  runit::service { 'carbon-cache':
    user    => '_graphite',
    group   => '_graphite',
    logdir  => '/var/log/carbon',
    rundir  => '/var/lib/graphite',
    content => '#!/bin/bash

envdir="/etc/sv/carbon-cache/env"
root=/var/lib/graphite
echo "Starting carbon-cache from ${root}"
cd $root
mkdir -p "${envdir}"
rm -f "${root}/carbon-cache.pid"
exec 2>&1
exec chpst -e "${envdir}" -u _graphite:_graphite /usr/bin/carbon-cache --debug --pidfile=carbon-cache.pid --config=/etc/carbon/carbon.conf start
',
    finish_command => '/usr/bin/carbon-cache --debug --pidfile=/var/lib/graphite/carbon-cache.pid --config=/etc/carbon/carbon.conf stop; rm -f /var/lib/graphite/carbon-cache.pid',
  }

  cron { 'purge stale collectd wsps':
    user    => '_graphite',
    minute  => '54',
    hour    => '12',
    command => 'find /var/lib/graphite/whisper/collectd/ -type f -mtime +60 -delete; find /var/lib/graphite/whisper/collectd/ -type d -empty -delete',
  }

}
