class c2corg::prod::env::symfony {

#TODO:
# - db-backend dans fichier hosts + .psqlrc
# - apache tuning, disable .htaccess
# - php + xcache tuning
# - keepalived

  file { "/srv/www":
    ensure => directory,
    owner  => "c2corg",
    group  => "c2corg",
  }

  vcsrepo { "/srv/www/camptocamp.org":
    ensure   => "present",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/camptocamp.org/",
    owner    => "c2corg",
    group    => "c2corg",
    require  => File["/srv/www"],
  }

  vcsrepo { "/srv/www/meta.camptocamp.org":
    ensure   => "present",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/meta.camptocamp.org/",
    owner    => "c2corg",
    group    => "c2corg",
    require  => File["/srv/www"],
  }

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

  include c2corg::password

  $sitename = "camptocamp.org"
  $smtp_server = "psemail.epfl.ch"
  $db_host = "192.168.192.5" # TODO: factorize
  $advertising_rw_dir = "/srv/www/camptocamp.org/www-data/persistent/advertising"

  file { "/home/c2corg/c2corg-envvars.sh":
    owner   => "c2corg",
    group   => "c2corg",
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'PRODUCTION'            => 'true',
    'DB_USER'               => '${c2corg::password::www_db_user}',
    'DB_PASS'               => '${c2corg::password::prod_db_pass}',
    'DB_HOST'               => '${db_host}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => 'http://s.${sitename}',
    'SMTP'                  => '${smtp_server}',
    'ADVERTISING_RW_DIR'    => '${advertising_rw_dir}',
    'ADVERTISING_ADMIN'     => '${c2corg::password::advertising_admin}',
    'GANALYTICS_KEY'        => '${c2corg::password::ganalytics_key}',
    'MOBILE_GANALYTICS_KEY' => '${c2corg::password::mobile_ganalytics_key}',
    'METAENGINE_KEY'        => '${c2corg::password::metaengine_key}',
    'GMAPS_KEY'             => '${c2corg::password::prod_gmaps_key}',
    'GEOPORTAIL_KEY'        => '${c2corg::password::geoportail_key}',
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  file { "c2corg prod.ini":
    path    => "/srv/www/camptocamp.org/deployment/prod.ini",
    source  => "file:///srv/www/camptocamp.org/deployment/conf.ini-dist",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { "metaengine databases.yml":
    path    => "/srv/www/meta.camptocamp.org/config/databases.yml",
    content => "# file managed by puppet
# DO NOT EDIT. DO NOT COMMIT.
all:
  myConnection:
    class: sfDoctrineDatabase
    param:
      dsn: pgsql://${c2corg::password::www_db_user}:${c2corg::password::prod_db_pass}@${db_host}:5432/metaengine
",
    require => Vcsrepo["/srv/www/meta.camptocamp.org"],
  }

  exec { "purge metaengine generated config":
    command     => "find /srv/www/meta.camptocamp.org/cache/frontend/prod/config/ -type f -delete",
    refreshonly => true,
    subscribe   => File["metaengine databases.yml"],
  }

  line { "import c2corg_vars in environment":
    ensure  => present,
    file    => "/home/c2corg/.bashrc",
    line    => ". ~/c2corg-envvars.sh",
    require => User["c2corg"],
  }

  sudoers { 'reformat-volatile.sh script':
    users => 'c2corg',
    type  => "user_spec",
    commands => [
      '(root) /srv/www/camptocamp.org/scripts/reformat-volatile.sh',
    ],
  }

  package { "postgis": ensure => present }

  Cron { environment => 'MAILTO="dev@camptocamp.org"', user => "c2corg" }

  cron { "buildC2cShapefiles":
    command => "sh /srv/www/camptocamp.org/batch/buildC2cShapefiles.sh",
    hour    => 5,
    minute  => 8,
    require => Package["postgis"],
  }

  cron { "latest_docs_rss":
    command => "sh /srv/www/camptocamp.org/batch/latest_docs_rss.sh",
    minute  => [15,45],
  }

  cron { "removeOldTempImages":
    command => "sh /srv/www/camptocamp.org/batch/removeOldTempImages.sh",
    minute  => 59,
    hour    => 2,
  }

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
