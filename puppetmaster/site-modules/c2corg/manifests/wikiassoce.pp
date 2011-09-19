class c2corg::wikiassoce {

  include c2corg::webserver::base

  package { "dokuwiki": ensure => present }

  file { "/etc/apache2/conf.d/dokuwiki.conf":
    ensure  => absent,
    require => Package["dokuwiki"],
    notify  => Exec["apache-graceful"],
  }

  apache::directive { "enable dokuwiki":
    vhost     => "dev.camptocamp.org",
    directive => "
Alias /wikiassoce /usr/share/dokuwiki/

<Directory /usr/share/dokuwiki/>
        Options +FollowSymLinks
        AllowOverride All
        order allow,deny
        allow from all
</Directory>
",
  }

}
