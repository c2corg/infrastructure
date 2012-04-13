class c2corg::backup {

  exec { "generate passwordless ssh key":
    command => 'ssh-keygen -f /root/.backupkey -P "" -t rsa',
    creates => ["/root/.backupkey.pub", "/root/.backupkey"],
  }

  if $::backupkey {
    include concat::setup

    $destdir = "/srv/backups/${::hostname}/"
    $destsrv = "backup.ghst.infra.camptocamp.org"

    concat { "/root/.backups.include":
      owner => "root",
      group => "root",
      mode  => "0644",
    }

    @@c2corg::ssh::userkey { "backup key for $::hostname":
      user    => "backup-${::hostname}",
      account => "root",
      type    => "rsa",
      key     => $::backupkey,
      opts    => "command=\"rsync --server -logDtprRe.iLsf --delete --numeric-ids . ${destdir}\",no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc,no-pty",
      tag     => "backups",
    }

    @@zfs { "srv/backups/$::hostname":
      ensure      => present,
      atime       => 'off',
      compression => 'gzip-1',
      dedup       => 'on',
      tag         => "backups",
    }

    cron { "rsync important stuff to backup server":
      command => "test ! -f /var/run/backup.lock && (touch /var/run/backup.lock && rsync --rsh='ssh -i /root/.backupkey' --archive --numeric-ids --delete --relative --quiet $(cat /root/.backups.include) root@${destsrv}:${destdir} || echo 'backup failed'; rm -f /var/run/backup.lock)",
      hour    => ip_to_cron(1, 6),
      minute  => ip_to_cron(),
    }
  }

  # ssh host keys should be managed in /etc/ssh/ssh_known_hosts or it's a bug.
  file { "/root/.ssh/known_hosts":
    ensure => absent,
  }

  # legacy common::concatfilepart dir
  file { "/root/.backups.include.d":
    ensure  => absent,
    purge   => true,
    force   => true,
    recurse => true,
  }
}
