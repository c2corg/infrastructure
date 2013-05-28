class c2corg::wikiassoce {

  include '::php::fpm'

  package { 'dokuwiki':
    ensure  => present,
    require => Service['php5-fpm'],
  } ->

  ::nginx::site { 'wikiassoce':
    source => 'puppet:///modules/c2corg/nginx/wikiassoce.conf',
  }

}
