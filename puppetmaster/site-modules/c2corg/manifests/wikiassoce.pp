class c2corg::wikiassoce {

  package { "dokuwiki": ensure => present }

  file { "/etc/apache2/conf.d/dokuwiki.conf":
    ensure  => absent,
    require => Package["dokuwiki"],
    notify  => Exec["apache-graceful"],
  }

}
