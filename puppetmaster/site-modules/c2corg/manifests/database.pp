class c2corg::database {

  class { 'postgresql::globals':
    encoding => 'UTF8',
  } ->
  class { 'postgresql::server':
    pg_hba_conf_defaults => false,
    manage_pg_hba_conf   => true,
    listen_addresses     => '*',
  } ->
  postgresql_psql {'Set template1 encoding to UTF8':
    command => "UPDATE pg_database
      SET datistemplate = FALSE
      WHERE datname = 'template1';
      UPDATE pg_database
      SET encoding = pg_char_to_encoding('UTF8'), datistemplate = TRUE
      WHERE datname = 'template1'",
    unless  => "SELECT datname FROM pg_database
      WHERE datname = 'template1' AND pg_encoding_to_char(encoding) = 'UTF8'",
  } ->
  class { 'postgis': }

  postgresql::server::pg_hba_rule { 'trust postgres user':
    type        => 'local',
    database    => 'all',
    user        => 'postgres',
    address     => undef,
    auth_method => 'peer',
    order       => '010',
  }

  postgresql::server::pg_hba_rule { 'forbid non-ssl connections':
    type        => 'host',
    database    => 'all',
    user        => 'all',
    address     => '0.0.0.0/0',
    auth_method => 'reject',
    order       => '015',
  }


  include ::postgresql::server::contrib
  include ::postgresql::params

  user {$::postgresql::params::user:
    ensure  => present,
    groups => ['ssl-cert'],
    require => Package['postgresql-server'],
  }

  file {"${::postgresql::server::datadir}/server.key":
    ensure  => link,
    target  => '/etc/ssl/private/ssl-cert-snakeoil.key',
  }
  file {"${::postgresql::server::datadir}/server.crt":
    ensure  => link,
    target  => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  }

  $www_db_user = hiera('www_db_user')
  $ml_db_user  = hiera('ml_db_user')

  postgis::database { ['c2corg', 'metaengine']:
    owner   => $www_db_user,
    charset => 'UTF-8',
  }

  postgresql::server::role { $www_db_user:
    password_hash => undef,
  }

  postgresql::server::role { $ml_db_user:
    password_hash => postgresql_password($ml_db_user, hiera('ml_db_pass')),
  }

}
