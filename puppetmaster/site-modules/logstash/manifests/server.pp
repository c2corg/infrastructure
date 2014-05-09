class logstash::server {

  package { 'logstash': ensure => present } ->

  etcdefault { 'start logstash at boot':
    file  => 'logstash',
    key   => 'START',
    value => 'yes',
  } ~>

  service { 'logstash':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
}
