class c2corg::devproxy::graphite {

  $collectd_host = hiera('collectd_host')

  nginx::site { 'graphite':
    content => template('c2corg/nginx/graphite.conf.erb'),
  }

}
