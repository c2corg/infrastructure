class c2cinfra::devproxy::puppetboard {

  ::nginx::site { 'puppetboard':
    source => 'puppet:///modules/c2cinfra/nginx/puppetboard.conf',
  }

}
