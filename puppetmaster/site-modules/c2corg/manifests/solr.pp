class c2corg::solr {

  $solr_version = '4.7.2'
  $dbhost = hiera('db_solr_host')
  $dbuser = hiera('solr_db_user')
  $dbpass = hiera('solr_db_pass')

  realize C2cinfra::Account::User['c2corg']

  apt::pin { 'backport_derby':
    packages => 'libderby-java',
    label    => 'C2corg',
    release  => 'wheezy',
    priority => '1100',
  }

  apt::pin { 'custom_solr_package':
    packages => 'solr',
    label    => 'C2corg',
    release  => 'wheezy',
    priority => '1100',
  }

  Etcdefault {
    file   => 'jetty8',
    notify => Service['jetty8'],
  }

  File {
    require => Package['solr'],
    before  => Service['jetty8'],
  }

  package { ['openjdk-7-jdk', 'jetty8', 'solr']: } ->
  package { ['libpostgresql-jdbc-java', 'libhsqldb-java', 'libderby-java']: } ->

  etcdefault {
    'enable jetty8 at boot':
      key   => 'NO_START',
      value => '0';
    'jetty8 java opts':
      key   => 'JAVA_OPTIONS',
      value => "\"-Xmx256m -Djava.awt.headless=true -Dsolr.solr.home=/srv/solr-dih/ -Dc2corg.dbhost=${dbhost} -Dc2corg.dbuser=${dbuser} -Dc2corg.dbpass=${dbpass}\"";
    'bind jetty to all ifaces':
      key   => 'JETTY_HOST',
      value => '127.0.0.1';
    'jetty uses default java':
      key   => 'JAVA_HOME',
      value => '/usr';
  } ->

  file { '/opt/solr':
    ensure => link,
    target => "/opt/solr-${solr_version}",
  }

  file { '/usr/share/jetty8/webapps/solr.war':
    ensure => link,
    target => "/opt/solr-${solr_version}/dist/solr-${solr_version}.war",
  }

  file { '/usr/share/jetty8/contexts/solr-jetty-context.xml':
    ensure => link,
    target => "/opt/solr-${solr_version}/example/contexts/solr-jetty-context.xml",
  }

  file { '/usr/share/jetty8/lib/ext':
    ensure => link,
    target => "/opt/solr-${solr_version}/example/lib/ext",
    force  => true,
  }

  vcsrepo { '/srv/solr-dih':
    ensure   => present,
    provider => 'git',
    source   => 'git://github.com/c2corg/solr-dih.git',
    owner    => 'c2corg',
    group    => 'c2corg',
  } ->

  file { '/srv/solr-dih/db/data':
    ensure => directory,
    owner  => 'jetty',
    group  => 'jetty',
  }

  file { '/srv/solr-dih/db/conf/dataimport.properties':
    ensure => present,
    owner  => 'jetty',
    group  => 'jetty',
  }

  service { 'jetty8':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  sudoers { 'restart jetty8':
    users    => 'c2corg',
    type     => 'user_spec',
    commands => [
      '(root) /etc/init.d/jetty8',
      '(root) /usr/sbin/invoke-rc.d jetty8 *',
      '(root) /usr/sbin/service jetty8 *',
    ],
  }

  sysctl::value {
    'kernel.shmmax': value => '37019648';
    'kernel.shmall': value => '2097152';
  } ->

  postgresql::server::config_entry {
    'max_standby_archive_delay'  : value => '-1';
    'max_standby_streaming_delay': value => '-1';
    'max_connections'            : value => '50';
  }

}
