class puppet::client {

  include augeas

  # undo workaround for expired release files in snapshot.debian.org
  apt::conf { "90snapshot-validity":
    ensure  => present,
    content => 'Acquire::Check-Valid-Until "true";',
  }

  apt::preferences { "puppet-packages_from_c2corg_repo":
    package  => "puppet puppetmaster puppet-common vim-puppet",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
    before   => [Package["puppet"], Package["augeas-lenses"]],
  }

  apt::preferences { "facter_from_c2corg_repo":
    package  => "facter",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
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
    context => "/files/etc/puppet/puppet.conf/puppetd",
    changes => "set certname $hostname",
    notify  => Service["puppet"],
  }

  # if datacenter fact is set, then pluginsync has successfully run at least
  # once.
  if ($datacenter and $hostname != "pm") {
    host { "pm.pse.infra.camptocamp.org":
      host_aliases => ["pm"],
      ip => $datacenter ? {
        /c2corg|epnet|pse/ => '192.168.192.101',
        default        => '128.179.66.13',
      },
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
