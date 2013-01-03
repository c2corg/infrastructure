# hiera lookup based on "duty" fact
class data::prod {

  $db_host      = '192.168.192.5'
  $session_host = '192.168.192.5'

  $symfony_master_host   = '192.168.192.4'
  $symfony_failover_host = '192.168.192.70'
  $c2cstats_host         = '192.168.192.75'
  $metac2c_host          = '192.168.192.4'
  $metaskirando_host     = '192.168.192.4'
  $varnish_host          = '192.168.192.60'

}
