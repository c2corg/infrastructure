define c2corg::devproxy::dashboard ($ensure='present', $vhost, $url, $location) {

  # todo: generate dashboard

  file { "/var/www/dev.camptocamp.org/private/dashboard-${name}.part":
    ensure  => $ensure,
    notify  => Exec["aggregate dashboard snippets"],
    content => "<li><a href='https://${vhost}${location}'>$name</a></li>\n",
  }

}
