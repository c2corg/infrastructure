# VM
node 'collectd0' inherits 'base-node' {

  fact::register {
    'role': value => 'metrics collection';
    'duty': value => 'prod';
  }

  #c2cinfra::backup::dir { [
  #  '/srv/carbon',
  #]: }

}
