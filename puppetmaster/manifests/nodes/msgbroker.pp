# VM
node 'msgbroker' inherits 'base-node' {

  include c2corg::rabbitmq

  fact::register { 'role': value => 'broker AMQP' }

}
