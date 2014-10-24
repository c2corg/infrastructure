# VM
node 'dnscache' {

  include c2cinfra::common
  include unbound

  fact::register {
    'role': value => ['dns cache'];
    'duty': value => 'prod';
  }

}
