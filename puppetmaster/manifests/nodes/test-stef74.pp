# VM
node 'test-stef74' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'stef74',
  }

  include '::c2corg::database::dev'
  include '::nginx'

  fact::register {
    'role': value => ['dev'];
    'duty': value => 'dev';
  }

  Etcdefault {
    file  => 'jetty',
  }

  package { 'solr-jetty':
    ensure => present,
  } ->
  # workaround for bug https://bugs.launchpad.net/ubuntu/+source/lucene-solr/+bug/1099320
  file { '/var/lib/jetty/webapps/solr':
    ensure => link,
    target => '/usr/share/solr/web',
  } ->
  etcdefault {
    'start jetty at boot time': key => 'NO_START', value => '0';
    'bind jetty to public interface': key => 'JETTY_HOST', value => '0.0.0.0';
  } ~>
  service { 'jetty':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  nginx::site { 'proxypass-jetty':
    content => '# file managed by puppet
server {
  listen 80;
  server_name test-stef74 test-stef74.dev.camptocamp.org test-stef74.pse.infra.camptocamp.org;

  location /solr/ {
    proxy_pass http://localhost:8080/solr/;
  }

  root /var/www;

}
',
  }

  c2cinfra::backup::dir {
    ['/srv/www/camptocamp.org/', '/home']:
  }

}
