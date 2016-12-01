# exoscale VM
node 'datamigration' {

  include c2cinfra::common

  c2cinfra::account::user { 'amorvan@root': user => 'amorvan', account => 'root' }
  c2cinfra::account::user { 'alex@root': user => 'alex', account => 'root' }
  c2cinfra::account::user { 'tsauerwein@root': user => 'tsauerwein', account => 'root' }

  fact::register {
    'role': value => ['datamigration'];
    'duty': value => 'prod';
  }
}
