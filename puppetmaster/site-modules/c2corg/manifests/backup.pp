class c2corg::backup {

  exec { "generate passwordless ssh key":
    command => 'ssh-keygen -f /root/.backupkey -P "" -t rsa',
    creates => ["/root/.backupkey.pub", "/root/.backupkey"],
  }

  if $backupkey {
    @@c2corg::sshuserkey { "backup key for $hostname":
      user    => "backup-${hostname}",
      account => "root",
      type    => "rsa",
      key     => $backupkey,
      opts    => "command=\"rsync --server -logDtprRe.iLsf --delete --numeric-ids . /srv/backups/mirror/${hostname}/\",no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc,no-pty",
      tag     => "backups",
    }

    cron { "rsync important stuff to backup server":
      command => "test ! -f /var/run/backup.lock && (touch /var/run/backup.lock && rsync --rsh='ssh -i /root/.backupkey' --archive --numeric-ids --delete --relative --quiet $(cat /root/.backups.include) root@backup.c2corg:/srv/backups/mirror/$(hostname)/ || echo 'backup failed'; rm -f /var/run/backup.lock)",
      hour    => ip_to_cron(1, 6),
      minute  => ip_to_cron(),
    }
  }

  # ssh host keys should be managed in /etc/ssh/ssh_known_hosts or it's a bug.
  file { "/root/.ssh/known_hosts":
    ensure => absent,
  }
}

define c2corg::backup::dir {

  include c2corg::backup

  $fname = regsubst($name, "\/", "_", "G")

  if $backupkey {
    common::concatfilepart { "include $fname in backups":
      file    => "/root/.backups.include",
      content => "${name}\n",
      manage  => true,
      before  => Cron["rsync important stuff to backup server"],
    }
  }
}

class c2corg::backup::server {

  file { ["/srv/backups", "/srv/backups/mirror", "/srv/backups/increments"]:
    ensure => directory,
  }

  C2corg::Sshuserkey <<| tag == 'backups' |>>

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
