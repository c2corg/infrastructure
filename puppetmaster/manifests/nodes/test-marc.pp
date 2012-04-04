# VM
node 'test-marc' inherits 'base-node' {

  fact::register { 'role': value => 'dev' }

}
