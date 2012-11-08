class c2corg::database::preprod inherits c2corg::database::common {

  $www_db_user = hiera('www_db_user')

  Postgresql::User[$www_db_user] {
    password => hiera('preprod_db_pass'),
  }

}
