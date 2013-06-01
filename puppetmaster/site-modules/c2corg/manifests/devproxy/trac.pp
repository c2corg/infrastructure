class c2corg::devproxy::trac {

  ::nginx::site { 'trac':
    source => 'puppet:///modules/c2corg/nginx/trac.conf',
  }
}
