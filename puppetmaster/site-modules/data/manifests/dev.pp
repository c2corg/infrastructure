# hiera lookup based on "duty" fact
class data::dev {

  $db_host       = '127.0.0.1'
  $session_hosts = ['127.0.0.1']
  $apache_disable_default_vhost = 'true'
}
