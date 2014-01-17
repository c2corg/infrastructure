class c2corg::mailinglists::webfetch {

  include '::phantomjs'

  file { '/var/cache/meteofrance':
    ensure => directory,
    owner  => 'nobody',
    group  => 'nogroup',
  } ->

  package { ['python-lxml', 'python-argparse']:
    ensure => present,
  } ->

  file { '/usr/local/bin/meteofrance.js':
    ensure => present,
    mode   => 755,
    source => 'puppet:///modules/c2corg/meteofrance/meteofrance.js',
  } ->

  file { '/usr/local/bin/meteofrance.py':
    ensure => present,
    mode   => 755,
    source => 'puppet:///modules/c2corg/meteofrance/meteofrance.py',
  } ->

  cron { 'bulletin nivo':
    ensure  => present,
    command => 'cd /usr/local/bin/ && ./meteofrance.py -m smtp --to dev@camptocamp.org 2>&1 | logger -i -t bulletin-nivo',
    user    => 'nobody',
    minute  => 15,
    hour    => [8,10,12,16,17,18,19],
    month   => [10,11,12,01,02,03,04,05,06],
  }

}
