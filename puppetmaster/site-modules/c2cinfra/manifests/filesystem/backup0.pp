class c2cinfra::filesystem::backup0 {

  $riemann_host = hiera('riemann_host')

  zpool { 'srv':
    mirror => ['sda3 sdb3'],
  }

  zfs { 'srv/backups': ensure => present }

  cron { 'zpool-riemann':
    command => "/usr/bin/timeout -s 9 30 /usr/local/sbin/zpool-riemann.py ${riemann_host} 1440 srv",
    minute  => '*/24',
    require => Class['hardware::raid::zfs'],
  }

}
