class c2cinfra::backup::server {

  apt::source { 'zfsonlinux':
    location => 'http://archive.zfsonlinux.org/debian',
    release  => "${::lsbdistcodename}",
    repos    => 'main',
  }

  apt::key { 'A71C1E00': }

  package { "linux-headers-${::kernelrelease}":
    before => Package['debian-zfs', 'zfsutils'],
  } ->
  package { ['debian-zfs', 'zfsutils']: } ->
  etcdefault { 'mount ZFS at boot':
    file  => 'zfs',
    key   => 'ZFS_MOUNT',
    value => 'yes',
  }

  C2cinfra::Ssh::Userkey <<| tag == 'backups' |>>
  Zfs <<| tag == 'backups' |>>

  @@sshkey { $::ipaddress:
    type => rsa,
    key  => $::sshrsakey,
    ensure => absent,
  }

  cron { 'daily backup increment':
    command => '/usr/local/sbin/increment-backups.sh',
    hour    => 11,
    minute  => 20,
  }

  file { '/usr/local/sbin/increment-backups.sh':
    mode    => '0755',
    owner   => 'root',
    before  => Cron['daily backup increment'],
    require => Package['debian-zfs'],
    content => '#!/bin/sh

export PATH="/bin:/sbin"
BASE="srv/backups"
DATEFMT="%d"

NEWINCR=$(date +$DATEFMT)
OLDINCR=$(date -d "now - 10 days" +$DATEFMT)

for node in $(ls /$BASE); do
  if zfs list -t snapshot | egrep -q "^$BASE/$node@$OLDINCR"; then
    zfs destroy $BASE/$node@$OLDINCR
  fi

  zfs snapshot $BASE/$node@$NEWINCR
done

',
  }

}
