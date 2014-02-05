class puppet::board {

  include '::uwsgi'
  include '::runit'

  if ($::lsbdistcodename == 'wheezy') {
    apt::pin { 'flask_from_c2corg_repo':
      packages => 'python-flask python-itsdangerous',
      label    => 'C2corg',
      priority => '1010',
    }

    apt::pin { 'python_requests_from_bpo':
      packages => 'python-requests python-urllib3',
      release  => "${::lsbdistcodename}-backports",
      priority => '1010',
    }
  }

  $puppetmaster_host = hiera('puppetmaster_host')

  package { 'python-puppetboard': ensure => present } ->

  file { '/etc/puppet/puppetboard.conf':
    ensure  => present,
    notify  => Runit::Service['puppetboard'],
    content => "# file managed by puppet
PUPPETDB_HOST = '${puppetmaster_host}'
PUPPETDB_PORT = 8081
PUPPETDB_SSL_VERIFY = False
PUPPETDB_KEY = '/srv/sslcerts/puppetboard-private.pem'
PUPPETDB_CERT = '/srv/sslcerts/puppetboard-ca.pem'
PUPPETDB_TIMEOUT = 20
#DEV_LISTEN_HOST = '127.0.0.1'
#DEV_LISTEN_PORT = 5000
UNRESPONSIVE_HOURS = 2
ENABLE_QUERY = True
LOGLEVEL = 'info'
",
  }

  file { ['/srv/sslcerts/puppetboard-ca.pem',
          '/srv/sslcerts/puppetboard-private.pem']:
    before  => Runit::Service['puppetboard'],
    mode    => '0640',
    owner   => 'root',
    group   => 'www-data',
  }

  realize Uwsgi::Plugin['python27']
  realize Uwsgi::Plugin['carbon']

  $carbon_host = hiera('carbon_host')

  file { ['/var/log/puppetboard', '/var/lib/puppetboard']:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  } ->

  file { '/srv/puppetboard':
    ensure => directory,
  } ->

  file { '/srv/puppetboard/wsgi.py':
    mode    => '0755',
    notify  => Runit::Service['puppetboard'],
    content => "# file managed by puppet
from __future__ import absolute_import
import os

# Needed if a settings.py file exists
os.environ['PUPPETBOARD_SETTINGS'] = '/etc/puppet/puppetboard.conf'
from puppetboard.app import app as application
",
  }

  file { '/srv/puppetboard/uwsgi.ini':
    notify  => Runit::Service['puppetboard'],
    content => "# file managed by puppet
[uwsgi]
  vacuum = true
  master = true
  wsgi-file = /srv/puppetboard/wsgi.py
  uwsgi-socket = 127.0.0.1:3032
  http-socket = 127.0.0.1:8081
  stats-server = 127.0.0.1:1718
  carbon-id = puppetboard
  plugin = carbon
  carbon = ${carbon_host}:2003
  die-on-term = true
  no-orphan = true
",
  }

  runit::service { 'puppetboard':
    user      => 'www-data',
    group     => 'www-data',
    rundir    => '/var/lib/puppetboard',
    logdir    => '/var/log/puppetboard',
    command   => '/usr/bin/uwsgi_python27 --ini /srv/puppetboard/uwsgi.ini',
    require   => Uwsgi::Plugin['python27'],
  }

}
