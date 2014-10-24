# VM
node 'lists' {

  include c2cinfra::common
  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers

  include c2corg::mailinglists

  fact::register {
    'role': value => ['mailinglists'];
    'duty': value => 'prod';
  }
}
