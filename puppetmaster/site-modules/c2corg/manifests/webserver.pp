class c2corg::webserver::base {

  include apache
  include php::apache

  augeas { "dont expose PHP version":
    changes => "set /files/etc/php5/apache2/php.ini/PHP/expose_php Off",
    notify  => Service["apache"],
  }

}

class c2corg::webserver::symfony {

  include c2corg::webserver::base
  include php

  apache::module { ["headers", "expires"]: }
  package { ["php5-pgsql", "php5-gd", "php-pear"]: }
  package { ["gettext", "msmtp"]: }

  # installed via an svn external from now on.
  package{ "php-symfony": ensure => absent }

  # fileinfo is included in recent PHPs
  if ($lsbdistcodename == 'lenny') {
    package { "php5-fileinfo": }
  }

  # short_open_tag conflicts with <?xml ... headers
  augeas { "disable php short open tags":
    changes => "set /files/etc/php5/apache2/php.ini/PHP/short_open_tag Off",
    notify  => Service["apache"],
  }

  # workaround while http://code.google.com/p/paver/issues/detail?id=53
  # prevents from building a debian package of python-jstools.
  package { "python-setuptools": }
  exec { "easy_install jstools":
    creates => "/usr/local/bin/jsbuild",
    require => Package["python-setuptools"],
  }
}

class c2corg::webserver::carto {

  include c2corg::webserver::base

  $epsg_file = "minimal"
  include c2corg::mapserver

  package { "gpsbabel": }
}

class c2corg::webserver::svg {

  include c2corg::webserver::base

  /* Fonts used by SVG routines */
  package { [
    "msttcorefonts", "gsfonts", "texlive-fonts-extra",
    "texlive-fonts-recommended", "gsfonts-x11",
    "ttf-bitstream-vera", "ttf-dejavu"]:
  }
}
