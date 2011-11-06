class c2corg::prod::env::postgres {

  Sysctl::Set_value { before => Service["postgresql"] }

  file { "/etc/postgresql/8.4/main/postgresql.conf":
    ensure => present,
    source => "puppet:///c2corg/pgsql/postgresql.conf.hn4",
    mode   => 0644,
    notify => Service["postgresql"],
  }

  sysctl::set_value {
    "kernel.shmmax": value => "4127514624";
    "kernel.shmall": value => "2097152";
  }

}
