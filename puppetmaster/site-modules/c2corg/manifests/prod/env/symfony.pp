class c2corg::prod::env::symfony {

  file { [
    "/srv/www/camptocamp.org/www-data",
    "/srv/www/camptocamp.org/www-data/volatile",
    "/srv/www/camptocamp.org/www-data/volatile/log", # symfony logfile
    "/srv/www/camptocamp.org/www-data/volatile/symfony", # symfony cache
    "/srv/www/camptocamp.org/www-data/volatile/forum", # forum cache
    "/srv/www/camptocamp.org/www-data/persistent",
    "/srv/www/camptocamp.org/www-data/persistent/uploads", # uploaded pictures
    "/srv/www/camptocamp.org/www-data/persistent/avatars", # forum avatars
    "/srv/www/camptocamp.org/www-data/persistent/advertising", # click counter
    ]:
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { [
    "/srv/www/meta.camptocamp.org/www-data",
    "/srv/www/meta.camptocamp.org/www-data/volatile",
    "/srv/www/meta.camptocamp.org/www-data/volatile/log", # symfony logfile
    "/srv/www/meta.camptocamp.org/www-data/volatile/symfony", # symfony cache
    "/srv/www/meta.camptocamp.org/www-data/persistent",
    ]:
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Vcsrepo["/srv/www/meta.camptocamp.org"],
  }

  # www.camptocamp.org
  file { "/srv/www/camptocamp.org/log":
    ensure => link,
    target => "/srv/www/camptocamp.org/www-data/volatile/log",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { "/srv/www/camptocamp.org/cache":
    ensure => link,
    target => "/srv/www/camptocamp.org/www-data/volatile/symfony",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { "/srv/www/camptocamp.org/web/forums/cache":
    ensure => link,
    target => "/srv/www/camptocamp.org/www-data/volatile/forum",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { "/srv/www/camptocamp.org/web/uploads":
    ensure => link,
    target => "/srv/www/camptocamp.org/www-data/persistent/uploads",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { "/srv/www/camptocamp.org/web/forums/img/avatars":
    ensure => link,
    target => "/srv/www/camptocamp.org/www-data/persistent/avatars",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  # meta.camptocamp.org
  file { "/srv/www/meta.camptocamp.org/log":
    ensure => link,
    target => "/srv/www/meta.camptocamp.org/www-data/volatile/log",
    require => Vcsrepo["/srv/www/meta.camptocamp.org"],
  }

  file { "/srv/www/meta.camptocamp.org/cache":
    ensure => link,
    target => "/srv/www/meta.camptocamp.org/www-data/volatile/symfony",
    require => Vcsrepo["/srv/www/meta.camptocamp.org"],
  }

  collectd::config::plugin { 'count photos':
    plugin   => 'filecount',
    settings => '
<Directory "/srv/www/camptocamp.org/www-data/persistent/uploads/images">
  Instance "images"
  Recursive false
</Directory>
<Directory "/srv/www/camptocamp.org/www-data/persistent/uploads/images_temp">
  Instance "images_temp"
  Recursive false
</Directory>
',
  }

  Cron { environment => 'MAILTO="dev@camptocamp.org"', user => "c2corg" }

  cron { "buildC2cShapefiles":
    command => "sh /srv/www/camptocamp.org/batch/buildC2cShapefiles.sh",
    hour    => 5,
    minute  => 8,
    require => Class["postgis::client"],
  }

  cron { "latest_docs_rss":
    command => "sh /srv/www/camptocamp.org/batch/latest_docs_rss.sh",
    minute  => [15,45],
  }

  cron { "removeOldTempImages as www-data":
    command => "sh /srv/www/camptocamp.org/batch/removeOldTempImages.sh",
    user    => 'www-data',
    minute  => 59,
    hour    => 2,
  }

  if ($::hostname !~ /failover/) {

    cron { "removeExpiredPendingUsers":
      command => "php -q /srv/www/camptocamp.org/batch/removeExpiredPendingUsers.php",
      minute  => 59,
      hour    => 0,
    }

    cron { "pushOutings":
      command => "php -q /srv/www/camptocamp.org/batch/pushOutings.php",
      minute  => 20,
    }
  }

}
