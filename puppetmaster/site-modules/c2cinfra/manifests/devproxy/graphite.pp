class c2cinfra::devproxy::graphite {

  $carbon_host = hiera('carbon_host')

  nginx::site { 'graphite':
    content => template('c2cinfra/nginx/graphite.conf.erb'),
  }

}
