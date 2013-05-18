class graphite::webapp {

  if (versioncmp($::operatingsystemrelease, 7) < 0) {
    fail('unsupported system')
  }

  include '::graphite'
  include '::uwsgi'
  include '::runit'

  realize Uwsgi::Plugin['python27']
  realize Uwsgi::Plugin['carbon']

  package { 'graphite-web':
    ensure => present
  } ->

  exec { 'graphite-manage syncdb --noinput':
    user    => '_graphite',
    creates => '/var/lib/graphite/graphite.db',
  } ->

  file { '/var/lib/graphite/graphite.db':
    owner => '_graphite',
    group => '_graphite',
  } ->

  file { '/etc/graphite/uwsgi.ini':
    ensure  => present,
    content => '
[uwsgi]
  vacuum = true
  master = true
  uwsgi-socket = 0.0.0.0:3031
  http-socket = 0.0.0.0:8080
  stats-server = 0.0.0.0:1717
  plugin = carbon
  carbon = 127.0.0.1:2003
  carbon-id = graphite-webapp
  gid = _graphite
  uid = _graphite
  wsgi-file = /usr/share/graphite-web/graphite.wsgi
',
  } ~>

  runit::service { 'graphite-webapp':
    user      => '_graphite',
    group     => '_graphite',
    rundir    => '/var/lib/graphite',
    logdir    => '/var/log/graphite',
    command   => '/usr/bin/uwsgi_python27 --ini /etc/graphite/uwsgi.ini',
    require   => Uwsgi::Plugin['python27'],
  }

  File_line {
    path    => '/etc/graphite/local_settings.py',
    notify  => Runit::Service['graphite-webapp'],
    require => Package['graphite-web'],
  }

  file_line {
    'set graphite timezone': line => "TIME_ZONE = 'Europe/Zurich'";
    'set graphite language': line => "LANGUAGE_CODE = 'fr-fr'";
    'set graphite auth':     line => "USE_REMOTE_USER_AUTHENTICATION = True";
  }

}
