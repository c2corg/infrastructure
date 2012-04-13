class c2corg::prod::fs::backup {

  zpool { 'srv': disk => 'xvdd' }

  zfs { 'srv/backups': ensure => present }

}
