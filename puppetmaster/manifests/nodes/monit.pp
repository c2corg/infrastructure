# VM - logs, stats and graphs
node 'monit' inherits 'base-node' {

  include c2corg::collectd::server
  include graphite::carbon
  include graphite::collectd
  include graphite::webapp
  include c2corg::syslog::server
  include c2corg::syslog::pgfouine
  include c2corg::syslog::haproxy
  include c2corg::prod::fs::monit

  $mpm_package = 'event'
  include apache

  apache::vhost { $fqdn: }

  c2corg::backup::dir { [
    "/var/lib/drraw",
    "/srv/carbon",
    "/var/www/",
  ]: }

}
