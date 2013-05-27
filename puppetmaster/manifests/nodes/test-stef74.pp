# VM
node 'test-stef74' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'stef74',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

  Etcdefault {
    file  => 'jetty',
  }

  package { 'solr-jetty':
    ensure => present,
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

}
