class c2corg::webserver::symfony {

  realize C2cinfra::Account::User['c2corg']

  include c2corg::webserver
  include php
  include postgresql::client

  apache::module { ["headers", "expires"]: }
  package { ["php5-pgsql", "php5-gd", "php-pear"]: }
  package { "gettext": }
  package { "imagemagick": }
  package { "ruby-sass": }

  # stuff no longer required on this system class
  package{ ["php-symfony", "msmtp"]: ensure => absent }

  # short_open_tag conflicts with <?xml ... headers
  augeas { 'disable php short open tags':
    incl    => '/etc/php5/apache2/php.ini',
    lens    => 'PHP.lns',
    changes => 'set PHP/short_open_tag Off',
    require => Package['libapache2-mod-php5'],
    notify  => Service['apache'],
  }

  # workaround while http://code.google.com/p/paver/issues/detail?id=53
  # prevents from building a debian package of python-jstools.
  # TODO: package this with fpm
  package { "python-setuptools": }
  exec { "easy_install jstools":
    creates => "/usr/local/bin/jsbuild",
    require => Package["python-setuptools"],
  }

  $sender_relay_map = "/etc/postfix/sender_relay"
  $sasl_pw_map      = "/etc/postfix/sasl_pw"

  postfix::config {
    "sender_dependent_relayhost_maps":      value => "hash:${sender_relay_map}";
    "smtp_sasl_password_maps":              value => "hash:${sasl_pw_map}";
    "smtp_sender_dependent_authentication": value => "yes";
    "smtp_sasl_security_options":           value => "noanonymous";
    "smtp_sasl_auth_enable":                value => "yes";
    "smtp_use_tls":                         value => "yes";
  }

  package { "libsasl2-modules": notify => Service["postfix"] }

  postfix::hash { $sender_relay_map:
    content => "noreply@camptocamp.org    [smtp.gmail.com]:587\n",
    before  => Postfix::Config["sender_dependent_relayhost_maps"],
  }

  $noreply_pass = hiera('noreply_pass')

  postfix::hash { $sasl_pw_map:
    content => "smtp.gmail.com    noreply@camptocamp.org:${noreply_pass}\n",
    before  => Postfix::Config["smtp_sasl_password_maps"],
  }

  file { "/srv/www":
    ensure => directory,
    owner  => "c2corg",
    group  => "c2corg",
  }

  vcsrepo { "camptocamp.org":
    name     => "/srv/www/camptocamp.org",
    ensure   => "present",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/camptocamp.org/",
    owner    => "c2corg",
    group    => "c2corg",
    require  => File["/srv/www"],
  }

  vcsrepo { "meta.camptocamp.org":
    name     => "/srv/www/meta.camptocamp.org",
    ensure   => "present",
    provider => "git",
    source   => "git://github.com/c2corg/meta.camptocamp.org.git",
    owner    => "c2corg",
    group    => "c2corg",
    require  => File["/srv/www"],
  }

  file { "c2corg conf.ini":
    source  => "file:///srv/www/camptocamp.org/deployment/conf.ini-dist",
    require => Vcsrepo["/srv/www/camptocamp.org"],
  }

  file { 'c2corg-envvars.sh':
    ensure  => present,
    mode    => 0755,
    path    => '/home/c2corg/c2corg-envvars.sh',
    owner   => 'c2corg',
    group   => 'c2corg',
    require => User['c2corg'],
  }

  file { "psql-env.sh":
    ensure => present,
    path   => "/etc/profile.d/psql-env.sh",
  }

  file { "/etc/profile.d/c2corg-env.sh":
    ensure  => present,
    require => File["c2corg-envvars.sh"],
    content => "# file managed by puppet
if [ -e ~/c2corg-envvars.sh ]; then
  . ~/c2corg-envvars.sh
fi
",
  }

  file_line { 'import c2corg_vars in environment':
    ensure  => absent,
    path    => '/home/c2corg/.bashrc',
    line    => '. ~/c2corg-envvars.sh',
    require => User['c2corg'],
  }
}
