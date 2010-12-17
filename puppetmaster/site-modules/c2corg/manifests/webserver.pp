class c2corg::webserver::base {

  include apache
  include php::apache

}

class c2corg::webserver::symfony {

  include c2corg::webserver::base
  include php

  apache::module { ["headers", "expires"]: }
  package { ["php-pear", "php5-xcache", "php-symfony"]: }
  package { "msmtp": }

  # fileinfo is included recent PHPs
  if ($lsbdistcodename == 'lenny') {
    package { "php5-fileinfo": }
  }
}

class c2corg::webserver::symfony::prod inherits c2corg::webserver::symfony {
  Package[ "php-symfony"] { ensure => "1.0.11-1" }
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
