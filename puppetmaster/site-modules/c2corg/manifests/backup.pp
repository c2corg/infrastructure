class c2corg::backup {

  exec { "generate passwordless ssh key":
    command => 'ssh-keygen -f /root/.backupkey -P "" -t rsa',
    creates => ["/root/.backupkey.pub", "/root/.backupkey"],
  }

  if $backupkey {
    @@c2corg::ssh::userkey { "backup key for $hostname":
      user    => "backup-${hostname}",
      account => "root",
      type    => "rsa",
      key     => $backupkey,
      opts    => "command=\"rsync --server -logDtprRe.iLsf --delete --numeric-ids . /srv/backups/mirror/${hostname}/\",no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc,no-pty",
      tag     => "backups",
    }

    cron { "rsync important stuff to backup server":
      command => "test ! -f /var/run/backup.lock && (touch /var/run/backup.lock && rsync --rsh='ssh -i /root/.backupkey' --archive --numeric-ids --delete --relative --quiet $(cat /root/.backups.include) root@backup.ghst.infra.camptocamp.org:/srv/backups/mirror/$(hostname)/ || echo 'backup failed'; rm -f /var/run/backup.lock)",
      hour    => ip_to_cron(1, 6),
      minute  => ip_to_cron(),
    }
  }

  # ssh host keys should be managed in /etc/ssh/ssh_known_hosts or it's a bug.
  file { "/root/.ssh/known_hosts":
    ensure => absent,
  }
}
