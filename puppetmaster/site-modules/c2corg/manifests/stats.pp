class c2corg::stats {

  $libdir     = '/var/lib/c2cstats'
  $conffile   = '/etc/c2cstats.conf'
  $cachedir   = "${libdir}/cache"
  $assetcache = "${cachedir}/assets"
  $assetdir   = "${libdir}/gen"
  $venv       = '/srv/c2cstats'
  $coderepo   = '/usr/src/c2c-stats'

  $python_version = '2.7'

  $secret_key = hiera('c2cstats_key')

  realize C2cinfra::Account::User['c2corg']

  class { 'python':
    version    => $python_version,
    dev        => true,
    virtualenv => true,
    gunicorn   => true,
  }

  vcsrepo { $coderepo:
    ensure   => present,
    owner    => 'c2corg',
    group    => 'c2corg',
    provider => 'git',
    source   => 'git://github.com/saimn/c2c-stats.git',
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

  file { [$libdir, $cachedir, $assetcache, $assetdir]:
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
    owner   => 'c2corg',
    content => "# file managed by puppet
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

  sudoers { 'restart gunicorn':
    users    => 'c2corg',
    type     => 'user_spec',
    commands => [
      '(root) /etc/init.d/gunicorn',
      '(root) /usr/sbin/invoke-rc.d gunicorn *',
    ],
  }

}
