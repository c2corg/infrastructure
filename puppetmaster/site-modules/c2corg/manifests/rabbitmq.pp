class c2corg::rabbitmq {

  include c2corg::password

  apt::preferences { "rabbitmq_from_c2corg_repo":
    package  => "rabbitmq-server",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
  }

  class { "rabbitmq::server":
    delete_guest_user => true,
  }

  rabbitmq_user { $c2corg::password::mco_user:
    ensure   => present,
    admin    => false,
    password => $c2corg::password::mco_pass,
  }

  rabbitmq_user_permissions { "${c2corg::password::mco_user}@/":
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
