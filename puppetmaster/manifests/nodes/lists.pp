# VM - mailinglists
node 'lists' inherits 'base-node' {

  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers

  include c2corg::mailinglists
  include c2corg::collectd::client

}
