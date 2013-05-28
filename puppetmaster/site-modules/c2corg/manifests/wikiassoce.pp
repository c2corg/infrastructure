class c2corg::wikiassoce {

  include '::php::fpm'

  package { 'dokuwiki':
    ensure  => present,
    require => Service['php5-fpm'],
  }

}
