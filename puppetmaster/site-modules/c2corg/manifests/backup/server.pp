class c2corg::backup::server {

  package { 'zfs-fuse': ensure => present }

  etcdefault { 'enable zfs at boot':
    key     => 'ENABLE_ZFS',
    file    => 'zfs-fuse',
    value   => 'yes',
    require => Package['zfs-fuse'],
    before  => Service['zfs-fuse'],
  }

  service { 'zfs-fuse':
    ensure    => running,
    hasstatus => false,
  }

  C2cinfra::Ssh::Userkey <<| tag == 'backups' |>>
  Zfs <<| tag == 'backups' |>>

  @@sshkey { $::ipaddress:
    type => rsa,
    key  => $::sshrsakey,
    ensure => absent,
  }

  cron { "daily backup increment":
    command => "/usr/local/sbin/increment-backups.sh",
    hour    => 11,
    minute  => 20,
  }

  file { "/usr/local/sbin/increment-backups.sh":
    mode    => 0755,
    owner   => "root",
    before  => Cron["daily backup increment"],
    require => Package["zfs-fuse"],
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
