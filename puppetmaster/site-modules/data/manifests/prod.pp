# hiera lookup based on "duty" fact
class data::prod {

  $db_host       = '192.168.192.52'
  $db_replication_master_host = '192.168.192.52'
  $session_hosts = ['192.168.192.65', '192.168.192.66']

  $symfony_master_host   = '192.168.192.62'
  $symfony_failover_host = '192.168.192.70'
  $c2cstats_host         = '192.168.192.75'
  $metac2c_host          = '192.168.192.62'
  $metaskirando_host     = '192.168.192.62'
  $v4redirections_host   = '192.168.192.62'
  $varnish_host          = '192.168.192.60'
  $solr_host             = '192.168.192.76'
  $camo_host             = '192.168.192.83'

}
