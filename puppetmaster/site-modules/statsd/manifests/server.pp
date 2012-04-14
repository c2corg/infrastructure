class statsd::server {

  package { 'python-statsd':
    ensure => present,
    before => Service['pystatsd-server'],
  }

  file { '/etc/init.d/pystatsd-server':
    ensure => present,
    mode   => 0755,
    before => Service['pystatsd-server'],
    source => 'puppet:///statsd/python-statsd.init',
  }

  file { '/var/run/pystatsd-server':
    ensure => directory,
    owner  => 'nobody',
    group  => 'nogroup',
    before => Service['pystatsd-server'],
  }

  service { 'pystatsd-server':
    ensure  => running,
    enable  => true,
    pattern => '^/usr/bin/python /usr/bin/pystatsd-server',
  }
}
