class hardware::raid::zfs {

  include riemann::client::python

  file { '/usr/local/sbin/zpool-riemann.py':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/hardware/zpool-riemann.py',
    require => Class['riemann::client::python'],
  }

}
