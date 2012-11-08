class c2corg::database {

  include postgresql
  include postgis

  $www_db_user = hiera('www_db_user')
  $ml_db_user  = hiera('ml_db_user')

  postgis::database { ["c2corg", "metaengine"]:
    ensure  => present,
    owner   => "www-data",
    require => Postgresql::User["www-data"],
  }

  postgresql::user { $www_db_user:
    ensure   => present,
  }

  postgresql::user { $ml_db_user:
    ensure   => present,
    password => hiera('ml_db_pass'),
  }

}
