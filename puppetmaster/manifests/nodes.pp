node 'base-node' {

  include os
  include apt
  include puppet::client
  include account

}

node 'c2cpc1.camptocamp.com' inherits 'base-node' {

  include puppet::server

  realize Account::User[marc]
}

node 'hn0-c2corg.camptocamp.com' inherits 'base-node' {

}
