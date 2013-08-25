# VM
node 'msgbroker' inherits 'base-node' {

  include c2cinfra::rabbitmq

  fact::register {
    'role': value => ['rabbitmq', 'message broker'];
    'duty': value => 'prod';
  }

}
