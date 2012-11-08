class c2corg::rabbitmq {

  #TODO: configure SSL + enable portfwd

  #@@nat::fwd { 'forward stomp port':
  #  host  => '55',
  #  from  => '61613',
  #  to    => '61613',
  #  proto => 'tcp',
  #  tag   => 'portfwd',
  #}

  $mco_user = hiera('mco_user')

  apt::preferences { "rabbitmq_from_c2corg_repo":
    package  => "rabbitmq-server",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
  }

  class { "rabbitmq::server":
    delete_guest_user => true,
  }

  rabbitmq_user { $mco_user:
    ensure   => present,
    admin    => false,
    password => hiera('mco_pass'),
  }

  rabbitmq_user_permissions { "${mco_user}@/":
    ensure               => present,
    configure_permission => "^amq.gen-.*",
    write_permission     => "^amq.(gen-.*|topic)",
    read_permission      => "^amq.(gen-.*|topic)",
  }

  rabbitmq_plugin { "rabbitmq_stomp":
    ensure => present,
    notify => Class["rabbitmq::service"],
  }

}
