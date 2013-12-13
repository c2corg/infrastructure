class puppet::server {

  package { ['puppetmaster', 'vim-puppet', 'puppet-lint', 'puppetdb', 'puppetdb-terminus']:
    ensure  => present,
  }

  service { 'puppetmaster':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    require    => Package['puppetmaster'],
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
    'master/reports': value => 'log,puppetdb,riemann';
    # config_version
    'marc/config_version':  value => '/usr/bin/git --git-dir /home/marc/infrastructure/.git rev-parse --short master 2>/dev/null || echo unknown';
    'main/config_version':  value => '/usr/bin/git --git-dir /srv/infrastructure/.git rev-parse --short master 2>/dev/null || echo unknown';
  }

  etcdefault { 'puppetdb java params':
    file   => 'puppetdb',
    key    => 'JAVA_ARGS',
    value  => '"-Xmx384m"',
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

  augeas { 'puppetdb database settings':
    incl    => '/etc/puppetdb/conf.d/database.ini',
    lens    => 'Rsyncd.lns',
    changes => [
      'set database/node-ttl 30d',
      'set database/node-purge-ttl 30d',
      'set database/report-ttl 14d',
    ],
    notify  => Service['puppetdb'],
  }

  sudoers { 'puppet server':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/bin/puppet cert *',
      '(root) /usr/bin/puppet node *',
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

  file { '/etc/puppet/hiera':
    ensure => directory,
    group  => 'adm',
    mode   => 2775,
  }

  $riemann_host = hiera('riemann_host')

  class { '::riemann::client::ruby': } ->
  file { '/etc/puppet/riemann.yaml':
    ensure  => present,
    notify  => Service['puppetmaster'],
    content => "---
:riemann_server: '${riemann_host}'
:riemann_port: 5555
",
  }

  collectd::config::plugin { 'monitor puppetmasterd':
    plugin   => 'processes',
    settings => 'ProcessMatch "puppetmasterd" "/usr/bin/puppet master"',
  }

  collectd::config::plugin { 'puppetdb metrics':
    plugin   => 'curl_json',
    settings => template('puppet/collectd-puppetdb.conf'),
  }

  collectd::config::chain { 'PuppetDbNiceNames':
    type     => 'precache',
    targets  => ['replace'],
    matches  => ['regex'],
    settings => '
<Rule "nice_names_for_puppetdb">
  <Match "regex">
    Plugin "^curl_json$"
    PluginInstance "^puppetdb_"
  </Match>
  <Target "replace">
    Plugin "curl_json" "puppetdb"
    PluginInstance "puppetdb_" ""
  </Target>
</Rule>
',
  }

}
