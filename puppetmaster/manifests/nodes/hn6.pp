# PowerEdge 1850
node 'hn6' inherits 'base-node' {

  include c2corg::hn::hn6

  include lxc::host

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
