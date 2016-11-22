# exoscale VM
node 'datamigration' {

  include c2cinfra::common

  c2cinfra::account::user { 'amorvan@root': user => 'amorvan', account => 'root' }

  fact::register {
    'role': value => ['datamigration'];
    'duty': value => 'prod';
  }
}
