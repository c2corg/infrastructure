class c2corg::prodenv::symfony {

#TODO:
# - server-status
# - db-backend dans fichier hosts + .psqlrc
# - apache tuning, disable .htaccess
# - php tuning
# - prod metrics

#postgres:
# 8 5 * * 1 cd /var/www/camptocamp.org/batch && sh buildC2cShapefiles.sh

#c2corg:
#20 * * * * /usr/bin/php -q /var/www/camptocamp.org/batch/pushOutings.php
#45 * * * * cd /var/www/camptocamp.org/batch && sh latest_docs_rss.sh
#59 0 * * * /usr/bin/php -q /var/www/camptocamp.org/batch/removeExpiredPendingUsers.php
#59 2 * * * cd /var/www/camptocamp.org/batch && sh removeOldTempImages.sh

  realize C2corg::Account::User["c2corg"]

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
  $db_host = "localhost"
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

  line { "import c2corg_vars in environment":
    ensure  => present,
    file    => "/home/c2corg/.bashrc",
    line    => ". ~/c2corg-envvars.sh",
    require => User["c2corg"],
  }

  #TODO: factorize
  resources { 'sudoers':
    purge => true,
  }

  #TODO: factorize
  Sudoers {
    hosts  => $hostname,
    target => "/etc/sudoers",
  }

  #TODO: factorize
  sudoers { 'Defaults':
    parameters => [
      '!authenticate',
      'env_reset',
      'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
    ],
    type => 'default',
  }

  sudoers { 'restart apache':
    users => 'c2corg',
    type  => "user_spec",
    commands => [
      '(root) /etc/init.d/apache',
      '(root) /usr/sbin/invoke-rc.d apache',
      '(root) /usr/sbin/apachectl',
      '(root) /usr/sbin/apache2ctl',
    ],
  }

  sudoers { 'do as c2corg':
    users => '%adm',
    type  => "user_spec",
    commands => [ '(c2corg) ALL' ],
  }

  sudoers { 'do as www-data':
    users => '%www-data',
    type  => "user_spec",
    commands => [ '(www-data) ALL' ],
  }

}

class c2corg::prodenv::postgres {

  Sysctl::Set_value { before => Service["postgresql"] }

  file { "/etc/postgresql/8.4/main/postgresql.conf":
    ensure => present,
    source => "puppet:///c2corg/pgsql/postgresql.conf.hn4",
    mode   => 0644,
    notify => Service["postgresql"],
  }

  sysctl::set_value {
    "kernel.shmmax": value => "4127514624";
    "kernel.shmall": value => "2097152";
  }

}
