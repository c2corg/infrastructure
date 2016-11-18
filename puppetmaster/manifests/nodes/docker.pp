# VM
node /^docker.*/ {

  include c2cinfra::common
  include docker

  fact::register {
    'role': value => ['docker'];
    'duty': value => 'prod';
  }
}
