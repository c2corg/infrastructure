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

  @@nat::fwd { 'forward puppetmaster port':
    host  => '101',
    from  => '8140',
    to    => '8140',
    proto => 'tcp',
    tag   => 'portfwd',
  }

  puppet::config {
    # certname
    'master/certname':    value => 'pm';
    # paths
    'master/modulepath':  value => '/srv/infrastructure/puppetmaster/modules:/srv/infrastructure/puppetmaster/site-modules';
    'master/manifestdir': value => '/srv/infrastructure/puppetmaster/manifests';
    'master/manifest':    value => '/srv/infrastructure/puppetmaster/manifests/site.pp';
    # environments
    'master/environments':  value => 'marc';
    'marc/modulepath':      value => '/home/marc/infrastructure/puppetmaster/modules:/home/marc/infrastructure/puppetmaster/site-modules';
    'marc/manifestdir':     value => '/home/marc/infrastructure/puppetmaster/manifests';
    'marc/manifest':        value => '/home/marc/infrastructure/puppetmaster/manifests/site.pp';
    # collected resources
    'master/storeconfigs':          value => true;
    'master/thin_storeconfigs':     value => false;
    'master/storeconfigs_backend':  value => 'puppetdb';
    'master/dbadapter':             value => '', ensure => absent;
    # reporting
    'master/reports': value => 'store,log,puppetdb';
  }

  etcdefault { 'puppetdb java params':
    file   => 'puppetdb',
    key    => 'JAVA_ARGS',
    value  => '"-Xmx256m"',
    notify => Service['puppetdb'],
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
      '(root) /usr/bin/puppet cert *',
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

  tidy { '/var/lib/puppet/reports/':
    age     => '2w',
    type    => 'mtime',
    recurse => true,
  }

  file { '/etc/puppet/hiera':
    ensure => directory,
    group  => 'adm',
    mode   => 2775,
  }

  cron { "restart puppetmaster": ensure => absent }

}
