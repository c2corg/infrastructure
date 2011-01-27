class puppet::client {

  include augeas

  apt::sources_list { "debian-snaphots-puppet-0.25.5":
    content => "# file managed by puppet
deb http://snapshot.debian.org/archive/debian/20100720T084354Z/ squeeze main
",
    require => Apt::Conf["90snapshot-validity"],
  }

  # workaround for expired release files in snapshot.debian.org
  # see http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=595801
  apt::conf { "90snapshot-validity":
    ensure  => present,
    content => 'Acquire::Check-Valid-Until "false";',
  }

  apt::preferences { "puppet-packages_from_snapshot":
    package  => "facter puppet puppetmaster puppet-common vim-puppet",
    pin      => "origin snapshot.debian.org",
    priority => "1010",
    before   => Package["puppet", "facter", "augeas-lenses"],
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

  host { "pm.c2corg":
    host_aliases => ["pm"],
    ip => $ipaddress ? {
      /192\.168\.19.*/ => '192.168.191.101',
      '128.179.66.13'  => '192.168.191.101',
      default          => '128.179.66.13',
    },
  }

}


class puppet::server {

  package { ["puppetmaster", "vim-puppet"]:
    ensure  => latest,
    require => Apt::Preferences["puppet-packages_from_snapshot"],
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
