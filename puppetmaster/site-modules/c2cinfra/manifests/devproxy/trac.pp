class c2cinfra::devproxy::trac {

  ::nginx::site { 'trac':
    source => 'puppet:///modules/c2cinfra/nginx/trac.conf',
  }
}
