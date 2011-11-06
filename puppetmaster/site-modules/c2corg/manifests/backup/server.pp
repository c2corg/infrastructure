class c2corg::backup::server {

  file { ["/srv/backups", "/srv/backups/mirror", "/srv/backups/increments"]:
    ensure => directory,
  }

  C2corg::Ssh::Userkey <<| tag == 'backups' |>>

  @@sshkey { "$ipaddress":
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
    content => '#!/bin/sh

BASE="/srv/backups/"
DATEFMT="%Y/%m/%d"
RETENSION=$(date -d "now - 10 days" +$DATEFMT)

MIRROR="$BASE/mirror/"
NEWINCR="$BASE/increments/$(date +$DATEFMT)"
OLDINCR="$BASE/increments/$RETENSION"

if [ -d $OLDINCR ]; then
  rm -fr $OLDINCR
fi

if ! [ -d $NEWINCR ]; then
  mkdir -p $NEWINCR
  for host in $MIRROR/*; do
    cp -al $host $NEWINCR/
  done
fi
',
  }

}
