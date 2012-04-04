class puppet::client {

  include augeas

  # undo workaround for expired release files in snapshot.debian.org
  apt::conf { "90snapshot-validity":
    ensure  => present,
    content => 'Acquire::Check-Valid-Until "true";',
  }

  apt::preferences { "puppet-packages_from_c2corg_repo":
    package  => "puppet puppetmaster puppetmaster-common puppet-common vim-puppet",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
    before   => [Package["puppet"], Package["augeas-lenses"]],
  }

  apt::preferences { "facter_from_c2corg_repo":
    package  => "facter",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
    before   => Package["puppet"],
  }

  package { ["puppet", "facter"]:
    ensure  => present,
  }

  service { "puppet":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [Package["puppet"], Augeas["enable puppetd at boot"]],
  }

  augeas { "enable puppetd at boot":
    context => "/files/etc/default/puppet",
    changes => "set START yes",
    before  => Service["puppet"],
  }

  augeas { "set puppet server":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set server pm",
    notify  => Service["puppet"],
  }

  augeas { "set puppet report_server":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set report_server pm",
    notify  => Service["puppet"],
  }

  augeas { "enable puppet reporting":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set report true",
    notify  => Service["puppet"],
  }

  augeas { "set puppet pluginsync":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set pluginsync true",
    notify  => Service["puppet"],
  }

  augeas { "set puppet certname":
    context => $::puppetversion ? {
      /^0\.2/ => "/files/etc/puppet/puppet.conf/puppetd",
      /^2\./  => "/files/etc/puppet/puppet.conf/agent",
    },
    changes => "set certname $::hostname",
    notify  => Service["puppet"],
  }

  augeas { "rm other puppet conf target":
    context => "/files/etc/puppet/puppet.conf/",
    changes => $::puppetversion ? {
      /^0\.2/ => "rm agent",
      /^2\./  => "rm puppetd",
    },
    notify  => Service["puppet"],
  }

  file { ["/etc/facter", "/etc/facter/facts.d"]:
    ensure  => directory,
    source  => "puppet:///c2corg/empty",
    recurse => true,
    purge   => true,
    force   => true,
  }

  # if datacenter fact is set, then pluginsync has successfully run at least
  # once.
  if ($::datacenter and $::hostname != "pm") {
    host { "pm.pse.infra.camptocamp.org":
      ip           => hiera('puppetmaster'),
      host_aliases => ["pm"],
    }
  }

  sudoers { 'puppet client':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/sbin/puppetd',
      '(root) /etc/init.d/puppet',
      '(root) /usr/sbin/invoke-rc.d puppet *',
    ],
  }

}
