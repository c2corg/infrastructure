class puppet::server {

  package { ["puppetmaster", "vim-puppet", "puppet-lint", "puppetdb", "puppetdb-terminus"]:
    ensure  => present,
  }

  service { "puppetmaster":
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    require    => Package["puppetmaster"],
  }

  service { 'puppetdb':
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => Package['puppetdb'],
    before    => Puppet::Config['master/storeconfigs_backend'],
  }

  Puppet::Config {
    notify => Service['puppetmaster'],
  }

  puppet::config {
    # certname
    'master/certname':    value => 'pm';
    # paths
    'master/modulepath':  value => '/srv/puppetmaster/modules:/srv/puppetmaster/site-modules';
    'master/manifestdir': value => '/srv/puppetmaster/manifests';
    'master/manifest':    value => '/srv/puppetmaster/manifests/site.pp';
    # environments
    'master/environments':  value => 'marc';
    'marc/modulepath':      value => '/home/marc/puppetmaster/modules:/home/marc/puppetmaster/site-modules';
    'marc/manifestdir':     value => '/home/marc/puppetmaster/manifests';
    'marc/manifest':        value => '/home/marc/puppetmaster/manifests/site.pp';
    # collected resources
    'master/storeconfigs':          value => true;
    'master/thin_storeconfigs':     value => false;
    'master/storeconfigs_backend':  value => 'puppetdb';
    'master/dbadapter':             value => '', ensure => absent;
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
