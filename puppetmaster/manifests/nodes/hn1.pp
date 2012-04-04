# ProLiant DL360 G4
node 'hn1' inherits 'base-node' {

  include c2corg::hn::hn1

  include c2corg::varnish::instance

  include c2corg::collectd::node

  fact::register { 'role': value => 'cache varnish' }
}
