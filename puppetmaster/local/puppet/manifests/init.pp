class puppet::client {

  package { ["puppet", "facter", "augeas-lenses"]:
    ensure => latest,
  }

  service { "puppet":
    enable  => true,
    ensure  => running,
    require => Package["puppet"],
  }

  augeas { "set puppet server":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => "set server c2cpc1.camptocamp.com",
  }

}


class puppet::server {

  package { ["puppetmaster", "vim-puppet"]:
    ensure => latest,
  }

  service { "puppetmaster":
    enable  => true,
    ensure  => running,
    require => Package["puppetmaster"],
  }

  augeas { "puppetmaster paths":
    context => "/files/etc/puppet/puppet.conf/puppetmasterd",
    changes => [
      "set modulepath /srv/puppetmaster/modules:/srv/puppetmaster/local",
      "set manifestdir /srv/puppetmaster/manifests",
    ],
  }

}
