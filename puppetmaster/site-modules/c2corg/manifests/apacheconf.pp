class c2corg::apacheconf {

  apache::vhost { "camptocamp.org":
    aliases => [
      "www.camptocamp.org",
      "s.camptocamp.org",
      "m.camptocamp.org",
      "symfony-backend.c2corg"],
    docroot => "/srv/www/camptocamp.org/web",
    cgibin  => false,
  }

  file { "/var/www/camptocamp.org/conf/camptocamp.org.conf":
    ensure  => link,
    target  => "/srv/www/camptocamp.org/config/camptocamp.org.conf",
    require => Apache::Vhost["camptocamp.org"],
  }

  apache::vhost { "meta.camptocamp.org":
    docroot => "/srv/www/meta.camptocamp.org/web",
    cgibin  => false,
  }

  file { "/var/www/meta.camptocamp.org/conf/camptocamp.org.conf":
    ensure  => link,
    target  => "/srv/www/meta.camptocamp.org/config/meta.camptocamp.org.conf",
    require => Apache::Vhost["meta.camptocamp.org"],
  }

}
