# VM
node 'pkg' {

  include c2cinfra::common
  include c2cinfra::reprepro

  fact::register {
    'role': value => ['reprepro', 'package repository'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/var/packages': }

}
