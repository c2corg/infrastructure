# hiera lookup, default fallback
class data::common {

  $db_port = '5432'
  $db_host = '127.0.0.1'
  $db_replication_master_host = '127.0.0.1'
  $db_solr_host = '127.0.0.1'
  $session_hosts = ['127.0.0.1']

  $pkgrepo_host = 'pkg.dev.camptocamp.org'

  $root_mail_recipient = 'invalid@email.tld'

  $carbon_host   = '192.168.192.127'
  $riemann_host  = '192.168.192.128'
  $statsd_host   = '192.168.192.127'
  $syslog_host   = '192.168.192.126'
  $logstash_host = '192.168.192.129'
  $broker_host   = '192.168.192.55'

  $puppetmaster_host = '192.168.192.101'

  $symfony_master_host   = '127.0.0.1'
  $symfony_failover_host = '127.0.0.1'
  $c2cstats_host         = '127.0.0.1'
  $metac2c_host          = '127.0.0.1'
  $metaskirando_host     = '127.0.0.1'
  $v4redirections_host   = '127.0.0.1'
  $varnish_host          = '127.0.0.1'

  $c2corg_vip = '128.179.66.23'

  $resolvers = ['8.8.8.8', '8.8.4.4']

  $www_db_user = "www-data"
  $ml_db_user = "sympa"
  $solr_db_user = "solr"
  $replication_db_user = "replication"
  $monit_db_user = "monitoring"

  # All defined keys & passwords. Values used in production are stored on the
  # puppetmaster in /etc/puppet/hiera/
  $prod_db_pass = "password"
  $preprod_db_pass = "password"
  $dev_db_pass = "password"
  $replication_db_pass = "password"
  $monit_db_pass = "password"

  $ml_db_pass = "password"
  $solr_db_pass = "password"

  $advertising_admin = "password"

  $noreply_pass = "password"

  $shared_crypt_pass = "JryqixNl7088w" # "password"

  $backup_vpn_password = "password"

  $lxc_root_password = "123"

  $prod_gmaps_key    = "invalid-key"
  $preprod_gmaps_key = "invalid-key"
  $prod_geoportail_key = "invalid-key"
  $preprod_geoportail_key = "invalid-key"
  $c2cstats_key = "sample-key"
  $metaengine_key = "sample-key"
  $ganalytics_key = "invalid-key"
  $mobile_ganalytics_key = "invalid-key"

  $duty = 'dev'

  $apache_disable_default_vhost = 'false'
}
