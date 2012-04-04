# PowerEdge 2950
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  include vz
  include c2corg::vz

  include c2corg::prod::fs::openvz

  include c2corg::collectd::node

  fact::register { 'role': 'HN openvz' }

  c2corg::backup::dir { "/etc/vz/conf/": }
}
