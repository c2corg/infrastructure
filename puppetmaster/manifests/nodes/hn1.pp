# ProLiant DL360 G4 - varnish
node 'hn1' inherits 'base-node' {

  include c2corg::hn::hn1

  include c2corg::varnish::instance

  include c2corg::collectd::client
}
