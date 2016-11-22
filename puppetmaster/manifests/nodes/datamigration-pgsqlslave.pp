# VM
node 'datamigration-pgsqlslave' {

  include c2cinfra::common

  fact::register {
    'role': value => ['datamigration db replica'];
    'duty': value => 'prod';
  }
}
