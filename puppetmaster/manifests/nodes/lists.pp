# VM
node 'lists' inherits 'base-node' {

  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers

  include c2corg::mailinglists

  fact::register {
    'role': value => 'distribution BRAs';
    'duty': value => 'prod';
  }
}
