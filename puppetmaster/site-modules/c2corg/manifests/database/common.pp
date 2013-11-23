class c2corg::database::common inherits c2corg::database {

  $www_db_user = hiera('www_db_user')
  $ml_db_user  = hiera('ml_db_user')

  Postgresql::Server::Pg_hba_rule {
    type        => 'hostssl',
    auth_method => 'md5',
    address     => '192.168.192.0/24',
    order       => '150',
  }

  postgresql::server::pg_hba_rule { 'symfony access to c2corg':
    database    => 'c2corg',
    user        => $www_db_user,
  }

  postgresql::server::pg_hba_rule { 'symfony access to metaengine':
    database    => 'metaengine',
    user        => $www_db_user,
  }

  postgresql::server::pg_hba_rule { 'sympa access to c2corg':
    database    => 'c2corg',
    user        => $ml_db_user,
  }

  package { ['pgtune', 'sysbench', 'ptop', 'check-postgres']: }

}
