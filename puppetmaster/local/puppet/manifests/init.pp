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
      "set manifest /srv/puppetmaster/manifests/site.pp",
    ],
    notify => Service["puppetmaster"],
  }

  augeas { "puppetmaster environments":
    context => "/files/etc/puppet/puppet.conf",
    changes => [
      "set puppetmasterd/environments marc",
      "set marc/modulepath /home/marc/puppetmaster/modules:/home/marc/puppetmaster/local",
      "set marc/manifestdir /home/marc/puppetmaster/manifests",
      "set marc/manifest /home/marc/puppetmaster/manifests/site.pp",
    ],
    notify => Service["puppetmaster"],
  }

  file { "/srv/puppetmaster/.git/hooks/post-update":
    ensure => present,
    mode   => "0755",
    source => "puppet:///puppet/post-update",
  }

}
