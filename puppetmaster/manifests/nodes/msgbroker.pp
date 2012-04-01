# VM - STOMP/AMQP message broker
node 'msgbroker' inherits 'base-node' {
  include c2corg::rabbitmq
}
