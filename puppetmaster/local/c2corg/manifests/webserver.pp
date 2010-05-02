class c2corg::webserver::base {

  include apache
  include php::apache

  $epsg_file = "minimal"
  include mapserver::debian

  apt::key { "5C662D02":
    source => "http://dev.camptocamp.com/packages/pub.key",
  }

  apt::sources_list { "c2corg-${lsbdistcodename}":
    ensure  => present,
    content => "deb http://dev.camptocamp.com/packages ${lsbdistcodename} c2corg\n",
  }

  package { [
    "php5-dev",
    "php-pear",
    "php5-xcache",
    "php5-fileinfo",
    ]:
  }

  package { "php-symfony": ensure => "1.0.11-1" }

  package { "gpsbabel": }

  package { "msmtp": }

  /* Fonts used by SVG routines */
  package { [
    "msttcorefonts",
    "gsfonts",
    "texlive-fonts-extra",
    "texlive-fonts-recommended",
    "gsfonts-x11",
    "ttf-bitstream-vera",
    "ttf-dejavu"]:
  }


  apache::module { ["headers", "expires"]: }

  apache::vhost { "camptocamp.org":
  }

  apache::vhost { "meta.camptocamp.org":
  }

  apache::vhost { "i18n.camptocamp.org":
  }

}

class c2corg::webserver::prod inherits c2corg::webserver::base {
}

class c2corg::webserver::dev inherits c2corg::webserver::base {
}
