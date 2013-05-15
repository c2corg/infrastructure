# PowerEdge 2950
node 'hn2' inherits 'base-node' {

  include c2cinfra::hn::hn2

  include vz
  include c2cinfra::containers

  include c2cinfra::filesystem::openvz

  fact::register {
    'role': value => 'HN openvz';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/etc/vz/conf/': }
}
