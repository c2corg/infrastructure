# VM
node 'datamigration' {

  include c2cinfra::common

  fact::register {
    'role': value => ['datamigration'];
    'duty': value => 'prod';
  }
}
