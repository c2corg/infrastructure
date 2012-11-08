class c2corg::database::dev inherits c2corg::database::common {

  $www_db_user = hiera('www_db_user')

  Postgresql::User[$www_db_user] {
    password => hiera('dev_db_pass'),
  }

}
