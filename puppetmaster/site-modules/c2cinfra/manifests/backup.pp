class c2cinfra::backup {

  exec { "generate passwordless ssh key":
    command => 'ssh-keygen -f /root/.backupkey -P "" -t rsa',
    creates => ["/root/.backupkey.pub", "/root/.backupkey"],
  }

  if $::backupkey {
    include concat::setup

    $destdir = "/srv/backups/${::hostname}/"
    $destsrv = "backup0.ovh.infra.camptocamp.org"
    $riemann = hiera('riemann_host')

    concat { "/root/.backups.include":
      owner => "root",
      group => "root",
      mode  => "0644",
    }

    @@c2cinfra::ssh::userkey { "backup key for $::hostname":
      user    => "backup-${::hostname}",
      account => "root",
      type    => "rsa",
      key     => $::backupkey,
      opts    => "command=\"rsync --server -logDtprRze.iLsf --delete --numeric-ids . ${destdir}\",no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc,no-pty",
      tag     => "backups",
    }

    @@zfs { "srv/backups/$::hostname":
      ensure      => present,
      atime       => 'off',
      compression => 'gzip-1',
      dedup       => 'on',
      tag         => "backups",
    }

    file { '/usr/local/bin/backup-host.sh':
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/c2cinfra/backup/backup-host.sh',
    } ->

    cron { 'rsync important stuff to backup server':
      command => "/usr/local/bin/backup-host.sh root@${destsrv}:${destdir} ${riemann}",
      hour    => fqdn_rand(6),
      minute  => fqdn_rand(59),
    }
  }

  # ssh host keys should be managed in /etc/ssh/ssh_known_hosts or it's a bug.
  file { "/root/.ssh/known_hosts":
    ensure => absent,
  }

}
