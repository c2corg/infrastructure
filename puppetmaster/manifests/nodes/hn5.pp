# PowerEdge 1850
node 'hn5' inherits 'base-node' {

  include c2corg::hn::hn6
  include c2corg::collectd::node

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
