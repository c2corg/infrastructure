class c2cinfra::wikiassoce {

  include '::php::fpm'

  package { 'dokuwiki':
    ensure  => present,
    require => Service['php5-fpm'],
  }

}
