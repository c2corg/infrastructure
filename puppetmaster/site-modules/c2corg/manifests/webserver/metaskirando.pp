class c2corg::webserver::metaskirando {

  vcsrepo { "metaskirando.camptocamp.org":
    name     => "/srv/www/metaskirando.camptocamp.org",
    ensure   => "present",
    provider => "git",
    source   => "git://github.com/c2corg/metaskirando.git",
    owner    => "c2corg",
    group    => "c2corg",
    require  => File["/srv/www"],
  }

  file { "/var/www/metaskirando.camptocamp.org/private/data":
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Apache::Vhost["metaskirando.camptocamp.org"],
  }

  if (hiera('duty') == 'prod') {
    cron { "update metaskirando data":
      command => "/srv/www/metaskirando.camptocamp.org/get_data 2>&1 | logger -i -t metaskirando",
      user    => "www-data",
      minute  => [0,15,30,45],
      require => File["/var/www/metaskirando.camptocamp.org/private/data"],
    }
  }

}
