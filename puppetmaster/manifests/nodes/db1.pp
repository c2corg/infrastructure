# VM
node 'db1' {

  include c2cinfra::common
  include c2corg::database::prod
  include c2corg::database::replication::slave
  include c2cinfra::filesystem::postgres91
  include c2corg::prod::env::postgres

  fact::register {
    'role': value => ['postgresql', 'main database', 'replica database'];
    'duty': value => 'prod';
  }

  include c2cinfra::backup::postgresql
  #c2cinfra::backup::dir { '/var/backups/pgsql': }

}
