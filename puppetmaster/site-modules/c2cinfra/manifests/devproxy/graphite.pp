class c2cinfra::devproxy::graphite {

  $collectd_host = hiera('collectd_host')

  nginx::site { 'graphite':
    content => template('c2cinfra/nginx/graphite.conf.erb'),
  }

}
