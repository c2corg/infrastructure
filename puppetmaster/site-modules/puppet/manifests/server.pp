class puppet::server {

  package { ["puppetmaster", "vim-puppet"]:
    ensure  => present,
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
    notify  => Service["puppetmaster"],
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

  sudoers { 'puppet server':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/sbin/puppetca',
      '(root) /etc/init.d/puppetmaster',
      '(root) /usr/sbin/invoke-rc.d puppetmaster *',
    ],
  }

  # puppetmaster leaks open FDs with sqlite :-(
  # TODO: remove this nonsense after upgrading puppet
  cron { "restart puppetmaster":
    command => "/etc/init.d/puppetmaster restart",
    minute  => ip_to_cron(),
    hour    => 4,
  }

}
