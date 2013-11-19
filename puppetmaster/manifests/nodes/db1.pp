# VM
node 'db1' inherits 'base-node' {

  include c2corg::database::prod
  include c2cinfra::filesystem::postgres91
  include c2corg::prod::env::postgres

  fact::register {
    'role': value => ['postgresql', 'main database'];
    'duty': value => 'prod';
  }

  class { 'postgresql::backup':
    backup_format => 'custom',
    backup_dir    => '/var/backups/pgsql',
  }

  c2cinfra::backup::dir { '/var/backups/pgsql': }

}
