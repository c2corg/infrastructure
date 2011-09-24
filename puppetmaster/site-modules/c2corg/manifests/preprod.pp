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

  #TODO: having this file managed by puppet is a nuisance.
  file { "c2corg preprod.ini":
    path    => "/srv/www/camptocamp.org/deployment/preprod.ini",
    source  => "puppet:///c2corg/symfony/preprod.ini",
    require => Vcsrepo["/srv/www/camptocamp.org/"],
    notify  => [Exec["c2corg refresh"], Exec["c2corg install"]],
  }

  exec { "c2corg install":
    command => "php c2corg --install --conf preprod",
    cwd     => "/srv/www/camptocamp.org/",
    require => [File["/srv/www/camptocamp.org/cache"], File["/srv/www/camptocamp.org/log"]],
    logoutput   => true,
    refreshonly => true,
  }

  exec { "c2corg refresh":
    command => "php c2corg --refresh --conf preprod --build",
    cwd     => "/srv/www/camptocamp.org/",
    require => Exec["c2corg install"],
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }
}
