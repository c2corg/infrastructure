class puppet::client {

  package { ["puppet", "facter", "augeas-lenses"]:
    ensure => latest,
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
    ensure => latest,
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

}
