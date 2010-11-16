class c2corg::database::base {

  include postgresql
  include postgis

  include c2corg::password

  postgis::database { ["c2corg", "metaengine"]:
    ensure  => present,
    owner   => "c2corg",
    require => Postgresql::User["c2corg"],
  }

  postgresql::user { "c2corg":
    ensure   => present,
    password => $c2corg::password::pgsql,
  }

  postgresql::user { "sympa":
    ensure   => present,
    password => $c2corg::password::sympa,
  }


}

class c2corg::database::prod inherits c2corg::database::base {
}

class c2corg::database::dev inherits c2corg::database::base {

  file { "/etc/postgresql/8.3/main/pg_hba.conf":
    ensure => "present",
    owner => "postgres",
    group => "postgres",
    mode => "0640",
    content => "local all all trust\nhost all all 127.0.0.1/32 trust\n",
    notify => Service["postgresql-8.3"],
    require => Package["postgresql-8.3"],
  }

}

