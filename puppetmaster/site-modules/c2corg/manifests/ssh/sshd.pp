class c2corg::ssh::sshd {

  file { "/etc/ssh/authorized_keys":
    ensure  => directory,
    mode    => 0644,
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///c2corg/empty/",
  }

  augeas { "sshd/AuthorizedKeysFile":
    context => "/files/etc/ssh/sshd_config/",
    changes => "set AuthorizedKeysFile /etc/ssh/authorized_keys/%u.keys",
    notify  => Service["ssh"],
    require => File["/etc/ssh/authorized_keys"],
  }

  package { "openssh-server":
    ensure => present,
    before => File["/etc/ssh/authorized_keys"],
  }

  service { "ssh":
    ensure  => running, hasstatus => true, enable => true,
    require => Package["openssh-server"],
  }

  # if datacenter fact is set, then pluginsync has successfully run at least
  # once.
  if $datacenter {
    # export and collect ssh host keys
    Sshkey { require => Package["openssh-server"] }
  }

  if ($fqdn != "" and $hostname != "") {

    resources { "sshkey": purge => true }
    Sshkey <<| |>>

    @@sshkey { "$fqdn":
      type => rsa,
      key  => $sshrsakey,
      host_aliases => [$hostname, $ipaddress],
    }
  }

  file { "/etc/ssh/ssh_known_hosts":
    ensure => present,
    mode   => 0644,
    owner  => "root",
  }

}
