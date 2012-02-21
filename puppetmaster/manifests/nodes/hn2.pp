# PowerEdge 2950 - virtualisation
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  include vz
  include c2corg::vz

  include c2corg::prod::fs::openvz

  include c2corg::collectd::client

}
