class c2cinfra::devproxy::wikiassoce {

  ::nginx::site { 'wikiassoce':
    source => 'puppet:///modules/c2cinfra/nginx/wikiassoce.conf',
  }
}
