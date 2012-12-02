# VM
node 'monit' inherits 'base-node' {

  include c2cinfra::collectd::server
  include graphite::carbon
  include graphite::collectd
  include graphite::webapp
  include statsd::server
  include c2cinfra::syslog::server
  include c2corg::syslog::pgfouine
  include c2corg::syslog::haproxy
  include c2corg::prod::fs::monit

  $mpm_package = 'event'
  include apache

  apache::vhost { $::fqdn : }

  fact::register {
    'role': value => ['collectd', 'graphite', 'syslog'];
    'duty': value => 'prod';
  }

  c2corg::backup::dir { [
    "/var/lib/drraw",
    "/srv/carbon",
    "/var/www/",
  ]: }

}
