# VM
node 'dnscache' inherits 'base-node' {

  include unbound

  fact::register { 'role': 'cache DNS subnet privé' }

}
