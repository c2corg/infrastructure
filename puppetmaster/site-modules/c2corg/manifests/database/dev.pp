class c2corg::database::dev inherits c2corg::database::common {

  $www_db_user = hiera('www_db_user')

  Postgresql::Server::Role[$www_db_user] {
    password_hash => postgresql_password($www_db_user, hiera('dev_db_pass')),
  }

  if str2bool($::vagrant) {

    postgresql::server::pg_hba_rule { 'access from vagrant':
      type        => 'hostssl',
      auth_method => 'md5',
      database    => 'all',
      user        => $www_db_user,
      address     => '10.0.0.0/8',
    }
  }

}
