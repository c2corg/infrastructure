# hiera lookup, default fallback
class data::common {

  $db_port = '5432'

  $pkgrepo = 'pkg.dev.camptocamp.org'

  $collectd = '192.168.192.126'
  $syslog   = '192.168.192.126'
  $broker   = '192.168.192.55'

  $puppetmaster = '192.168.192.101'

}
