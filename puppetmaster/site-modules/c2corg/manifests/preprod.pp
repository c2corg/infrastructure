class c2corg::preprod::autoupdate {


  /* hackish stuff to autotomatically install and update c2corg codebase */
  vcsrepo { "/srv/www/camptocamp.org/":
    ensure   => "latest",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/camptocamp.org/",
    notify   => Exec["c2corg refresh"],
  }

  vcsrepo { "/srv/www/meta.camptocamp.org":
    ensure   => "latest",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/meta.camptocamp.org/",
  }

  file { [
      "/srv/www/camptocamp.org/cache",
      "/srv/www/camptocamp.org/log",
      "/srv/www/meta.camptocamp.org/cache",
      "/srv/www/meta.camptocamp.org/log",
    ]:
    ensure  => directory,
    owner   => "www-data",
    require => [Vcsrepo["/srv/www/camptocamp.org/"], Vcsrepo["/srv/www/meta.camptocamp.org"]],
  }

  file { "c2corg preprod.ini":
    path    => "/srv/www/camptocamp.org/deployment/preprod.ini",
    source  => "file:///srv/www/camptocamp.org/deployment/conf.ini-dist",
    require => Vcsrepo["/srv/www/camptocamp.org/"],
    notify  => [Exec["c2corg refresh"], Exec["c2corg install"]],
  }

  include c2corg::password
  $db_user = "www-data"
  $sitename = "pre-prod.dev.camptocamp.org"
  $c2corg_vars = "DB_USER=${db_user};DB_PASS=${c2corg::password::pgsql};SERVER_NAME=www.${sitename};MOBILE_VERSION_HOST=m.${sitename};CLASSIC_VERSION_HOST=www.${sitename};STATIC_HOST=s.${sitename};STATIC_BASE_URL=http://s.${sitename}"

  exec { "c2corg install":
    command => "C2CORG_VARS='${c2corg_vars}' php c2corg --install --conf preprod",
    cwd     => "/srv/www/camptocamp.org/",
    require => [File["/srv/www/camptocamp.org/cache"], File["/srv/www/camptocamp.org/log"]],
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }

  exec { "c2corg refresh":
    command => "C2CORG_VARS='${c2corg_vars}' php c2corg --refresh --conf preprod --build",
    cwd     => "/srv/www/camptocamp.org/",
    require => Exec["c2corg install"],
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }
}
