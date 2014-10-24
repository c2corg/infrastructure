# VM
node 'riemann' {

  include c2cinfra::common
  include '::riemann::server'
  include '::riemann::dash'

  fact::register {
    'role': value => ['riemann'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir {
    ['/etc/riemann']:
  }


}
