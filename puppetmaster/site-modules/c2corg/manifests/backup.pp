class c2corg::backup {

  exec { "generate passwordless ssh key":
    command => 'ssh-keygen -f /root/.backupkey -P "" -t rsa',
    creates => ["/root/.backupkey.pub", "/root/.backupkey"],
  }

  if $backupkey {
    @@c2corg::sshkey { "backup key for $hostname":
      user    => "backup-${hostname}",
      account => "root",
      type    => "rsa",
      key     => $backupkey,
      opts    => "no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc,no-pty",
      tag     => "backups",
    }
  }
}

class c2corg::backup::server {

  file { "/backups":
    ensure => directory,
  }

  package { "pdumpfs": }

  C2corg::Sshkey <<| tag == 'backups' |>>


}

define c2corg::backup::dir {

  include c2corg::backup
  # TODO
}
