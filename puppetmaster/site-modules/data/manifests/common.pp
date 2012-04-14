# hiera lookup, default fallback
class data::common {

  $db_port = '5432'

  $pkgrepo_host = 'pkg.dev.camptocamp.org'

  $collectd_host = '192.168.192.126'
  $statsd_host   = '192.168.192.126'
  $syslog_host   = '192.168.192.126'
  $broker_host   = '192.168.192.55'

  $puppetmaster_host = '192.168.192.101'

}
