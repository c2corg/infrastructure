# VM
node 'camo' inherits 'base-node' {
  
  fact::register {
    'role': value => ['image proxy'];
    'duty': value => 'prod';
  }
}
