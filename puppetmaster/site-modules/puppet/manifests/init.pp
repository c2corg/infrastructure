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
    ensure  => latest,
  }

  service { "puppet":
    enable  => true,
    ensure  => running,
    pattern => "ruby1.8 /usr/sbin/puppetd$",
    require => [Package["puppet"], Augeas["enable puppetd at boot"]],
  }

  augeas { "enable puppetd at boot":
    context => "/files/etc/default/puppet",
    changes => "set START yes",
  }

  augeas { "set puppet server":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set server pm",
  }

  augeas { "set puppet pluginsync":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set pluginsync true",
  }

  augeas { "set puppet certname":
    context => "/files/etc/puppet/puppet.conf/puppetd",
    changes => "set certname $hostname",
  }

  # if datacenter fact is set, then pluginsync has successfully run at least
  # once.
  if ($datacenter and $hostname != "pm") {
    host { "pm.psea.infra.camptocamp.org":
      host_aliases => ["pm"],
      ip => $datacenter ? {
        /c2corg|epnet/ => '192.168.191.101',
        default        => '128.179.66.13',
      },
    }
  }

}


class puppet::server {

  package { ["puppetmaster", "vim-puppet"]:
    ensure  => latest,
    require => Apt::Preferences["puppet-packages_from_c2corg_repo"],
  }

  service { "puppetmaster":
    enable  => true,
    ensure  => running,
    require => Package["puppetmaster"],
  }

  augeas { "set puppetmaster certname":
    context => "/files/etc/puppet/puppet.conf/puppetmasterd",
    changes => "set certname pm",
  }

  augeas { "puppetmaster paths":
    context => "/files/etc/puppet/puppet.conf/puppetmasterd",
    changes => [
      "set modulepath /srv/puppetmaster/modules:/srv/puppetmaster/site-modules",
      "set manifestdir /srv/puppetmaster/manifests",
      "set manifest /srv/puppetmaster/manifests/site.pp",
    ],
    notify => Service["puppetmaster"],
  }

  augeas { "puppetmaster environments":
    context => "/files/etc/puppet/puppet.conf",
    changes => [
      "set puppetmasterd/environments marc",
      "set marc/modulepath /home/marc/puppetmaster/modules:/home/marc/puppetmaster/site-modules",
      "set marc/manifestdir /home/marc/puppetmaster/manifests",
      "set marc/manifest /home/marc/puppetmaster/manifests/site.pp",
    ],
    notify => Service["puppetmaster"],
  }

  augeas { "enable collected resources":
    context => "/files/etc/puppet/puppet.conf/puppetmasterd",
    changes => [
      "set storeconfigs true",
      "set dbadapter sqlite3",
      "set thin_storeconfigs true",
    ],
    notify => Service["puppetmaster"],
  }

  package { ["sqlite3", "libsqlite3-ruby"]:
    ensure => present,
    before => Augeas["enable collected resources"],
  }

}

class puppet::devel {

  package { ["rake", "rubygems", "librspec-ruby", "libmocha-ruby"]: ensure => present }

}
