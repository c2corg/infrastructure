class c2corg::stats {

  include c2corg::password

  $libdir   = '/var/lib/c2cstats'
  $conffile = '/etc/c2cstats.conf'
  $cachedir = "${libdir}/cache"
  $assetdir = "${libdir}/gen"
  $venv     = '/srv/c2cstats'
  $coderepo = '/usr/src/c2c-stats'

  $python_version = '2.7'

  $secret_key = $c2corg::password::c2cstats_key

  class { 'python':
    version    => $python_version,
    dev        => true,
    virtualenv => true,
    gunicorn   => true,
  }

  vcsrepo { $coderepo:
    ensure   => present,
    provider => 'git',
    source   => 'git://github.com/mfournier/c2c-stats.git',
    revision => 'chgmts-avant-mise-en-prod',
  }

  package { ['python-numpy', 'libevent-dev']:
    ensure => present,
    before => Python::Virtualenv[$venv],
  }

  python::virtualenv { $venv:
    version    => $python_version,
    systempkgs => true,
  }

  python::requirements { "${$coderepo}/requirements.txt":
    virtualenv => $venv,
    require    => Vcsrepo[$coderepo],
    notify     => Python::Gunicorn['c2cstats'],
  }

  file { [$libdir, $cachedir, $assetdir]:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    before => Python::Gunicorn['c2cstats'],
  }

  file { "${venv}/lib/python${python_version}/site-packages/c2cstats":
    ensure  => link,
    target  => "${coderepo}/c2cstats",
    require => [Vcsrepo[$coderepo], Python::Virtualenv[$venv]],
  }

  file { "${venv}/lib/python${python_version}/site-packages/c2cstats/static/gen":
    ensure => link,
    target => "${libdir}/gen",
    before => Python::Gunicorn['c2cstats'],
  }

  file { $conffile:
    ensure  => present,
    content => "
DEBUG = False
SECRET_KEY = '${secret_key}'
CACHE_TYPE = 'filesystem'
CACHE_DIR = '${libdir}/cache'
CACHE_THRESHOLD = 10000
",
  }

  python::gunicorn { 'c2cstats':
    virtualenv  => $venv,
    template    => 'c2corg/gunicorn/c2cstats.conf.erb',
    dir         => $libdir,
    require     => File[$conffile],
  }

}
