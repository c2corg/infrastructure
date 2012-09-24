class puppet::server {

  package { ["puppetmaster", "vim-puppet", "puppet-lint", "puppetdb", "puppetdb-terminus"]:
    ensure  => present,
    require => Apt::Preferences["puppet-packages_from_c2corg_repo"],
  }

  service { "puppetmaster":
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    require    => Package["puppetmaster"],
  }

  service { "puppetdb":
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    require    => Package["puppetdb"],
  }

  augeas { "set puppetmaster certname":
    context => "/files/etc/puppet/puppet.conf/master",
    changes => "set certname pm",
    notify  => Service["puppetmaster"],
  }

  augeas { "puppetmaster paths":
    context => "/files/etc/puppet/puppet.conf/master",
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
      "set master/environments marc",
      "set marc/modulepath /home/marc/puppetmaster/modules:/home/marc/puppetmaster/site-modules",
      "set marc/manifestdir /home/marc/puppetmaster/manifests",
      "set marc/manifest /home/marc/puppetmaster/manifests/site.pp",
    ],
    notify => Service["puppetmaster"],
  }

  augeas { "enable collected resources":
    context => "/files/etc/puppet/puppet.conf/master",
    changes => [
      "set storeconfigs true",
      "rm dbadapter",
      "set thin_storeconfigs false",
      "set storeconfigs_backend puppetdb",
    ],
    notify  => Service["puppetmaster"],
    require => Service['puppetdb'],
  }

  augeas { 'puppetdb java opts':
    changes => 'set /files/etc/default/puppetdb/JAVA_ARGS "-Xmx256m"',
    notify  => Service['puppetdb'],
  }

  file { '/etc/puppet/puppetdb.conf':
    content => '[main]
server = pm
port = 8081
',
    notify  => Service['puppetdb'],
    require => Package['puppetmaster'],
    before  => Service['puppetmaster'],
  }

  sudoers { 'puppet server':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/sbin/puppetca',
      '(root) /etc/init.d/puppetmaster',
      '(root) /etc/init.d/puppetdb',
      '(root) /usr/sbin/invoke-rc.d puppetmaster *',
      '(root) /usr/sbin/invoke-rc.d puppetdb *',
    ],
  }

  augeas { "rm puppetmasterd":
    context => "/files/etc/puppet/puppet.conf",
    changes => "rm puppetmasterd",
    notify  => Service["puppetmaster"],
  }

  file { '/etc/puppet/hiera.yaml':
    ensure  => present,
    content => '---
:backends: - yaml
           - puppet
:hierarchy: - %{hostname}
            - %{duty}
            - %{datacenter}
            - common
:yaml:
    :datadir: /etc/puppet/hiera

:puppet:
    :datasource: data
',
  }

  file { '/etc/puppet/hiera': ensure => directory }

  cron { "restart puppetmaster": ensure => absent }

}
