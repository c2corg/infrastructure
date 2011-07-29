define c2corg::sshuserkey ($user, $account, $type, $key, $opts='') {

  $comment = "$user on $account"
  $sshopts = $opts ? {
    '' => '',
    default => "$opts ", # note ending whitespace
  }

  common::concatfilepart { "sshkey-for-${user}-on-${account}":
    file    => "/etc/ssh/authorized_keys/${account}.keys",
    content => "${sshopts}ssh-${type} ${key} ${comment}\n",
    manage  => true,
  }
}

class c2corg::sshd {

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

  # export and collect ssh host keys

  Sshkey { require => Package["openssh-server"] }

  @@sshkey { "$fqdn":
    type => rsa,
    key  => $sshrsakey
  }

  @@sshkey { "$hostname":
    type => rsa,
    key  => $sshrsakey
  }

  @@sshkey { "$ipaddress":
    type => rsa,
    key  => $sshrsakey
  }

  Sshkey <<| |>>

  resources { "sshkey": purge => true }

  file { "/etc/ssh/ssh_known_hosts":
    ensure => present,
    mode   => 0644,
    owner  => "root",
  }

}
