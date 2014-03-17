# VM
node 'monit' inherits 'base-node' {

  include c2cinfra::syslog::server
  include c2corg::syslog::haproxy

  $mpm_package = 'event'
  include apache

  apache::vhost { $::fqdn : }

  fact::register {
    'role': value => ['syslog'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/var/www/',
  ]: }

}
