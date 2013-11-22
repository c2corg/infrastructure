class c2corg::database::preprod inherits c2corg::database::common {

  $www_db_user = hiera('www_db_user')

  Postgresql::Server::Role[$www_db_user] {
    password_hash => postgresql_password($www_db_user, hiera('preprod_db_pass')),
  }

}
