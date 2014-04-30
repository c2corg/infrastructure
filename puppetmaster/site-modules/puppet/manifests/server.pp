class puppet::server {

#TODO: apply https://github.com/dalen/puppet/commit/29d7997c

  include 'apache::ssl'

  Apache::Listen <| title == '80' |> { ensure => absent }
  Apache::Listen <| title == '443' |> { ensure => absent }
  Apache::Namevhost <| title == '*:80' |> { ensure => absent }
  Apache::Namevhost <| title == '*:443' |> { ensure => absent }

  apt::pin { 'puppetmaster-packages_from_c2corg_repo':
    packages => 'puppetmaster puppetmaster-common puppetmaster-passenger puppetdb puppetdb-terminus',
    label    => 'C2corg',
    release  => "${::lsbdistcodename}",
    priority => '1010',
  }

  package { ['puppetmaster', 'puppetmaster-passenger', 'vim-puppet', 'puppet-lint', 'puppetdb', 'puppetdb-terminus']:
    ensure  => present,
  } ->

  apache::listen { '8140': } ->

  apache::confd { 'passenger':
    configuration => '
# you probably want to tune these settings
PassengerHighPerformance on

# Set this to about 1.5 times the number of CPU cores in your master:
PassengerMaxPoolSize 6

# Stop processes if they sit idle for 10 minutes
PassengerPoolIdleTime 600

# Recycle master processes after they service 1000 requests
# PassengerMaxRequests 1000

PassengerStatThrottleRate 120
RackAutoDetect Off
RailsAutoDetect Off
',
  } ->

  apache::vhost { 'puppetmaster':
    config_content => "
<VirtualHost *:8140>
        SSLEngine on
        SSLProtocol -ALL +SSLv3 +TLSv1
        SSLCipherSuite ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP

        SSLCertificateFile      /var/lib/puppet/ssl/certs/${::hostname}.pem
        SSLCertificateKeyFile   /var/lib/puppet/ssl/private_keys/${::hostname}.pem
        SSLCertificateChainFile /var/lib/puppet/ssl/certs/ca.pem
        SSLCACertificateFile    /var/lib/puppet/ssl/certs/ca.pem
        # If Apache complains about invalid signatures on the CRL, you can try disabling
        # CRL checking by commenting the next line, but this is not recommended.
        SSLCARevocationFile     /var/lib/puppet/ssl/ca/ca_crl.pem
        SSLVerifyClient optional
        SSLVerifyDepth  1
        # The `ExportCertData` option is needed for agent certificate expiration warnings
        SSLOptions +StdEnvVars +ExportCertData

        # This header needs to be set if using a loadbalancer or proxy
        RequestHeader unset X-Forwarded-For

        RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e
        RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e
        RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e

        DocumentRoot /usr/share/puppet/rack/puppetmasterd/public/
        RackBaseURI /
        <Directory /usr/share/puppet/rack/puppetmasterd/>
                Options None
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>
",
  } ->

  file_line { 'passenger needs to run in an utf-8 environment':
    path   => '/etc/apache2/envvars',
    line   => 'export LANG="en_US.UTF-8"',
    notify => Service['apache'],
  }

  service { 'puppetmaster':
    enable     => false,
    ensure     => stopped,
    hasstatus  => true,
    require    => Package['puppetmaster'],
  }

  etcdefault { 'disable puppetmaster at boot':
    file   => 'puppetmaster',
    key    => 'START',
    value  => 'no',
  }

  service { 'puppetdb':
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => Package['puppetdb'],
    before    => Puppet::Config['master/storeconfigs_backend'],
  }

  Puppet::Config {
    notify => Service['apache'],
  }

  @@nat::fwd { '001 forward puppetmaster port':
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
    'master/reports': value => 'log,puppetdb,riemann,graphite';
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
    before  => Service['apache'],
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
    users => '%puppetmasters',
    type  => "user_spec",
    commands => [
      '(root) /usr/bin/puppet cert *',
      '(root) /usr/bin/puppet node *',
      '(root) /etc/init.d/puppetmaster',
      '(root) /etc/init.d/puppetdb',
      '(root) /usr/sbin/invoke-rc.d puppetmaster *',
      '(root) /usr/sbin/invoke-rc.d puppetdb *',
      '(root) /usr/sbin/service puppetmaster *',
      '(root) /usr/sbin/service puppetdb *',
    ],
  }

  file { '/etc/puppet/hiera.yaml':
    ensure  => present,
    content => '---
:backends:
  - yaml
  - puppet
:hierarchy:
  - "%{hostname}"
  - "%{duty}"
  - "%{datacenter}"
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
    notify  => Service['apache'],
    content => "---
:riemann_server: '${riemann_host}'
:riemann_port: 5555
",
  }

  $carbon_host = hiera('carbon_host')

  file { '/etc/puppet/graphite.yaml':
    ensure  => present,
    notify  => Service['apache'],
    content => "---
:graphite_server: '${carbon_host}'
:graphite_port: 2003
",
  }

  group { 'puppetmasters': ensure => present }

  User <| title == 'marc' or title == 'xbrrr' |> {
    groups +> 'puppetmasters',
  }

  collectd::config::plugin { 'monitor puppetmasterd':
    plugin   => 'processes',
    settings => 'ProcessMatch "puppetmasterd" "^Rack:.*puppetmasterd"',
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
