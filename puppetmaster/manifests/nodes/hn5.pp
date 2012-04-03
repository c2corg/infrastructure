# PowerEdge 1850 - varnish
node 'hn5' inherits 'base-node' {

  include c2corg::hn::hn5

  include c2corg::collectd::node

}
