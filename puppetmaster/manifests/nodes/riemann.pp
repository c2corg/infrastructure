# VM
node 'riemann' inherits 'base-node' {

  include '::riemann'
  include '::riemann::dash'

  fact::register {
    'role': value => ['riemann'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir {
    ['/etc/riemann', '/var/run/riemann-dash']:
  }


}
