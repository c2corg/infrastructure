# ProLiant DL360 G4p
node 'hn0' inherits 'base-node' {

  include c2cinfra::hn::hn0

  include vz
  include c2cinfra::containers

  include c2cinfra::openvpn

  include c2cinfra::filesystem::openvz

  fact::register {
    'role': value => ['HN openvz', 'routeur'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/etc/vz/conf/': }
}
