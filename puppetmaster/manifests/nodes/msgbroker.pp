# VM
node 'msgbroker' inherits 'base-node' {

  include c2cinfra::rabbitmq

  fact::register {
    'role': value => 'broker AMQP';
    'duty': value => 'prod';
  }

}
