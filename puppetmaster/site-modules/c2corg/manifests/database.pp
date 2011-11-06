class c2corg::database {

  include postgresql
  include postgis

  include c2corg::password

  postgis::database { ["c2corg", "metaengine"]:
    ensure  => present,
    owner   => "www-data",
    require => Postgresql::User["www-data"],
  }

  postgresql::user { "${c2corg::password::www_db_user}":
    ensure   => present,
  }

  postgresql::user { "${c2corg::password::ml_db_user}":
    ensure   => present,
    password => $c2corg::password::ml_db_pass,
  }

}
