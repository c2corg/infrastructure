class c2corg::trac {

  include '::uwsgi'
  include '::runit'

  package { ['sqlite3', 'graphviz', 'libjs-jquery']:
    ensure => present,
  } ->

  package { ['trac', 'trac-accountmanager', 'trac-email2trac', 'trac-mastertickets', 'trac-wikirename', 'trac-git']:
    ensure => present,
    before => Runit::Service['trac'],
  }

  realize Uwsgi::Plugin['python27']
  realize Uwsgi::Plugin['carbon']

  $carbon_host = hiera('carbon_host')

  file { ['/var/log/trac', '/var/lib/trac']:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  } ->

  file { '/srv/trac/projects/c2corg/conf/uwsgi.ini':
    content => "# file managed by puppet
[uwsgi]
  vacuum = true
  master = true
  module = trac.web.main:dispatch_request
  env = TRAC_ENV=/srv/trac/projects/c2corg/
  uwsgi-socket = 127.0.0.1:3031
  http-socket = 127.0.0.1:8080
  stats-server = 127.0.0.1:1717
  carbon-id = trac
  plugin = carbon
  carbon = ${carbon_host}:2003
  die-on-term = true
  no-orphan = true
",
  } ~>

  runit::service { 'trac':
    user      => 'www-data',
    group     => 'www-data',
    rundir    => '/var/lib/trac',
    logdir    => '/var/log/trac',
    command   => '/usr/bin/uwsgi_python27 --ini /srv/trac/projects/c2corg/conf/uwsgi.ini',
    require   => Uwsgi::Plugin['python27'],
  }

# trac upgrade notes:
# trac-admin . upgrade
# trac-admin . wiki upgrade
# trac-admin . deploy /tmp/toto
# cp /tmp/toto/cgi-bin/trac.cgi in cgi-bin
# cp logo in htdocs
# trac-admin . resync

}
