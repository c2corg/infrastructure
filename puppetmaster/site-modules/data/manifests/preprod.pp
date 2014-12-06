# hiera lookup based on "duty" fact
class data::preprod {

  $db_host       = '127.0.0.1'
  $session_hosts = ['127.0.0.1']
  $solr_host     = '192.168.192.76'
  $camo_host     = '192.168.192.83'
}
