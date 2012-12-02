class c2cinfra::filesystem::backup {

  zpool { 'srv': disk => 'xvdd' }

  zfs { 'srv/backups': ensure => present }

}
