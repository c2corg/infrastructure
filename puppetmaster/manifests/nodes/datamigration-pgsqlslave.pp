# exoscale VM
node 'datamigration-pgsqlslave' {

  include c2cinfra::common

  fact::register {
    'role': value => ['datamigration db replica'];
    'duty': value => 'prod';
  }

  # nb: postgresql 9.6 installed and setup manually
  class { 'postgresql::globals':
    version => '9.6',
  } ->
  class { 'postgresql::server':
    manage_pg_hba_conf   => false,
    listen_addresses     => 'localhost',
  }

  include c2cinfra::backup::postgresql
  c2cinfra::backup::dir { '/var/backups/pgsql': }

}
