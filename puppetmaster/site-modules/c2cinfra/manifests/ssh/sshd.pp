class c2cinfra::ssh::sshd {

  file { "/etc/ssh/authorized_keys":
    ensure  => directory,
    mode    => 0644,
    recurse => true,
    purge   => true,
    force   => true,
  }

  augeas { 'sshd/AuthorizedKeysFile':
    incl    => '/etc/ssh/sshd_config',
    lens    => 'Sshd.lns',
    changes => 'set AuthorizedKeysFile /etc/ssh/authorized_keys/%u.keys',
    notify  => Service['ssh'],
    require => File['/etc/ssh/authorized_keys'],
  }

  augeas { 'sshd/UseDNS':
    incl    => '/etc/ssh/sshd_config',
    lens    => 'Sshd.lns',
    changes => 'set UseDNS no',
    notify  => Service['ssh'],
  }

  $pwauth = str2bool($::vagrant) ? {
    true  => 'yes',
    false => 'no',
  }

  augeas { 'sshd/PasswordAuthentication':
    incl    => '/etc/ssh/sshd_config',
    lens    => 'Sshd.lns',
    changes => "set PasswordAuthentication ${pwauth}",
    notify  => Service['ssh'],
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
  if $::datacenter {
    # export and collect ssh host keys
    Sshkey { require => Package["openssh-server"] }
  }

  if ($::fqdn != "" and $::hostname != "") {

    resources { "sshkey": purge => true }
    Sshkey <<| |>>

    @@sshkey { $::fqdn:
      type => rsa,
      key  => $::sshrsakey,
      host_aliases => [
        $::hostname,
        regsubst($::fqdn, '.infra.camptocamp.org$', ''),
        regsubst($::fqdn, '.camptocamp.org$', ''),
        $::ipaddress,
      ],
    }
  }

  file { "/etc/ssh/ssh_known_hosts":
    ensure => present,
    mode   => 0644,
    owner  => "root",
  }

}
