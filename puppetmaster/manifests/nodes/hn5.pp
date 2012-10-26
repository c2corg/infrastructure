# PowerEdge 1850
node 'hn5' {

  include apt
  include c2corg::apt::wheezy
  include c2corg::common::config
  include c2corg::common::services
  include c2corg::common::packages
  include c2corg::collectd::node
  include c2corg::hn::hn5

  fact::register {
    'role': value => 'tests lxc';
    'duty': value => 'dev';
  }

  include lxc::host

}
