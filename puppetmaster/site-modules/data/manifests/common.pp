# hiera lookup, default fallback
class data::common {

  $db_port = '5432'

  $pkgrepo_host = 'pkg.dev.camptocamp.org'

  $collectd_host = '192.168.192.126'
  $statsd_host   = '192.168.192.126'
  $syslog_host   = '192.168.192.126'
  $broker_host   = '192.168.192.55'

  $puppetmaster_host = '192.168.192.101'

  $www_db_user = "www-data"
  $ml_db_user = "sympa"
  $mco_user = "mco"

  # All defined keys & passwords. Values used in production are stored on the
  # puppetmaster in /etc/puppet/hiera/
  $prod_db_pass = "password"
  $preprod_db_pass = "password"
  $dev_db_pass = "password"

  $mco_pass = "password"
  $mco_psk  = "psk"

  $ml_db_pass = "password"

  $advertising_admin = "password"

  $noreply_pass = "password"

  $shared_crypt_pass = "JryqixNl7088w" # "password"

  $lxc_root_password = "123"

  $prod_gmaps_key    = "invalid-key"
  $preprod_gmaps_key = "invalid-key"
  $prod_geoportail_key = "invalid-key"
  $preprod_geoportail_key = "invalid-key"
  $c2cstats_key = "sample-key"
  $metaengine_key = "sample-key"
  $ganalytics_key = "invalid-key"
  $mobile_ganalytics_key = "invalid-key"

}
