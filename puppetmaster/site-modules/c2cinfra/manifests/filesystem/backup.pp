class c2cinfra::filesystem::backup {

  zpool { 'srv': disk => 'xvdc' }

  zfs { 'srv/backups': ensure => present }

}
