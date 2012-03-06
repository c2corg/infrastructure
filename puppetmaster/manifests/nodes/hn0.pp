# ProLiant DL360 G4p - main router + virtualisation
node 'hn0' inherits 'base-node' {

  include c2corg::hn::hn0

  include vz
  include c2corg::vz

  include c2corg::prod::fs::openvz

  include c2corg::collectd::client

  c2corg::backup::dir { "/etc/vz/conf/": }
}
