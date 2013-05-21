# VM
node 'test-stef74' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'stef74',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

  package { 'solr-jetty':
    ensure => present,
  } ->
  etcdefault { 'start jetty at boot time':
    file  => 'jetty',
    key   => 'NO_START',
    value => '0',
  } ~>
  service { 'jetty':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

}
