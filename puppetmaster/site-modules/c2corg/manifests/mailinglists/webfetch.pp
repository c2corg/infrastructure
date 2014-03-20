class c2corg::mailinglists::webfetch {

  user { 'webfetch':
    ensure     => present,
    managehome => true,
  } ->

  file { '/home/webfetch/.msmtprc':
    ensure  => present,
    mode    => '0600',
    owner   => 'webfetch',
    group   => 'webfetch',
    content => '# file managed by puppet
defaults
syslog on

account sympa
host lists.pse.infra.camptocamp.org
port 25
from nobody@lists.camptocamp.org

account default: sympa
',
  }

  include '::phantomjs'

  package { 'msmtp': ensure => present } ->

  file { '/var/cache/meteofrance':
    ensure => directory,
    owner  => 'webfetch',
    group  => 'webfetch',
  } ->

  package { ['python-lxml', 'python-argparse']:
    ensure => present,
  } ->

  vcsrepo { '/srv/nivo-bulletins':
    ensure   => present,
    owner    => 'webfetch',
    group    => 'webfetch',
    provider => 'git',
    source   => 'https://github.com/c2corg/nivo-bulletins.git',
  } ->

  cron { 'bulletin nivo':
    ensure  => present,
    command => 'cd /srv/nivo-bulletins && ./meteofrance.py -m msmtp 2>&1 | logger -i -t bulletin-nivo',
    user    => 'webfetch',
    minute  => 15,
    hour    => [8,10,12,16,17,18,19],
    month   => [10,11,12,01,02,03,04,05,06],
  }

  sudoers { 'access to webfetch account for admins':
    users => '%adm',
    type  => "user_spec",
    commands => [ '(webfetch) ALL' ],
  }


  file { ['/usr/local/bin/meteofrance.js', '/usr/local/bin/meteofrance.py']:
    ensure => absent,
  }

}
