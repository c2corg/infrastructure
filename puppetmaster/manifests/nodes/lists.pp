# VM
node 'lists' inherits 'base-node' {

  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers

  include c2corg::mailinglists
  include c2corg::collectd::node

  fact::register {
    'role': value => 'distribution BRAs';
    'duty': value => 'prod';
  }
}
