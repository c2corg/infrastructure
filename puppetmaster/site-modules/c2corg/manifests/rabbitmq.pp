class c2corg::rabbitmq {

  include c2corg::password

  apt::preferences { "rabbitmq_from_c2corg_repo":
    package  => "rabbitmq-server",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
  }

  class { "rabbitmq::server":
    delete_guest_user => false,
  }

  rabbitmq_user { $c2corg::password::mco_rabbitmq_uname:
    ensure   => present,
    admin    => false,
    password => $c2corg::password::mco_rabbitmq_passwd,
  }

  rabbitmq_plugin { "rabbitmq_stomp":
    ensure => present,
    notify => Class["rabbitmq::service"],
  }

}
