class c2cinfra::filesystem::backup0 {

  zpool { 'srv':
    mirror => ['sda3 sdb3'],
  }

  zfs { 'srv/backups': ensure => present }

}
