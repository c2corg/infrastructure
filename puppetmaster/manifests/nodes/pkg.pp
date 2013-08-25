# VM
node 'pkg' inherits 'base-node' {

  include c2cinfra::reprepro

  fact::register {
    'role': value => ['reprepro', 'package repository'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/srv/deb-repo/': }

}
