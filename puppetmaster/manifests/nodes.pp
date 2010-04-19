node 'base-node' {

  include os
  include apt
  include puppet::client

}

node 'c2cpc1.camptocamp.com' inherits 'base-node' {

  include puppet::server

}
