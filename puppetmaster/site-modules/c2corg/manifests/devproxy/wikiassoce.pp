class c2corg::devproxy::wikiassoce {

  ::nginx::site { 'wikiassoce':
    source => 'puppet:///modules/c2corg/nginx/wikiassoce.conf',
  }
}
