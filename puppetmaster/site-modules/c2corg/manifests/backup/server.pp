class c2corg::backup::server {

  package { "btrfs-tools": ensure => present }

  file { ["/srv/backups", "/srv/backups/SNAPSHOTS"]:
    ensure => directory,
  }

  C2corg::Ssh::Userkey <<| tag == 'backups' |>>

  @@sshkey { $ipaddress:
    type => rsa,
    key  => $sshrsakey,
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
    require => Package["btrfs-tools"],
    content => '#!/bin/sh

BASE="/srv/backups/"
DATEFMT="%d"
RETENSION=$(date -d "now - 10 days" +$DATEFMT)

NEWINCR="$BASE/SNAPSHOTS/$(date +$DATEFMT)"
OLDINCR="$BASE/SNAPSHOTS/$RETENSION"

if [ -d $OLDINCR ]; then
  btrfs subvolume delete $OLDINCR
fi

if ! [ -d $NEWINCR ]; then
  btrfs subvolume snapshot $BASE $NEWINCR || exit 1
  date > $NEWINCR/snapshot.date
else
  echo "snapshot failed: $NEWINCR already present"
  exit 1
fi
',
  }

}
