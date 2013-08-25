# X3550 M3
node 'hn4' inherits 'base-node' {

  include c2cinfra::hn::hn4

  include c2corg::database::prod
  include c2cinfra::filesystem::postgres
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
