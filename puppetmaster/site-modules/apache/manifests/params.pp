class apache::params {

  $pkg = 'apache2'

  $root = '/var/www'

  $user = 'www-data'
  $group = 'www-data'

  $conf = '/etc/apache2'

  $log = '/var/log/apache2'
  $access_log = "${log}/access.log"
  $error_log = "${log}/error.log"

  $a2ensite = '/usr/sbin/a2ensite'

}
