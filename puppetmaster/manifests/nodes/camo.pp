# VM
node 'camo' {

  include c2cinfra::common

  include c2corg::camo
  
  fact::register {
    'role': value => ['image proxy'];
    'duty': value => 'prod';
  }
}
