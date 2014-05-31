class hardware::raid::smartarray {

  package { ["cpqarrayd", "arrayprobe", "cciss-vol-status"]:
    ensure => present,
  }

  service { "cpqarrayd":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/sbin/cpqarrayd",
    require   => Package["cpqarrayd"],
  }

  $riemann_host = hiera('riemann_host')

  include riemann::client::python

  file { '/usr/local/sbin/cciss-riemann.py':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/hardware/cciss-riemann.py',
    require => [Package['cciss-vol-status'], Class['riemann::client::python']],
  } ->

  cron { 'cciss-riemann':
    command => "/usr/bin/timeout -s 9 30 /usr/local/sbin/cciss-riemann.py ${riemann_host} 1440",
    minute  => '*/12',
  }


}
