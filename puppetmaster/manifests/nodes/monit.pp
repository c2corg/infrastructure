# VM
node 'monit' inherits 'base-node' {

  include graphite::legacy::carbon
  include graphite::legacy::collectd
  include graphite::legacy::webapp
  include statsd::server::python
  include c2cinfra::syslog::server
  include c2corg::syslog::pgfouine
  include c2corg::syslog::haproxy
  include c2cinfra::filesystem::monit

  $mpm_package = 'event'
  include apache

  apache::vhost { $::fqdn : }

  fact::register {
    'role': value => ['collectd', 'graphite', 'syslog'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/var/lib/drraw',
    '/srv/carbon',
    '/var/www/',
  ]: }

}
