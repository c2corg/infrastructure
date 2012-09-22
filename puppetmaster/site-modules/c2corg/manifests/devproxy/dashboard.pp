define c2corg::devproxy::dashboard ($ensure='present', $vhost, $url, $location) {

  # todo: generate dashboard

  $htpasswd = "/srv/trac/projects/c2corg/conf/htpasswd"

  apache::proxypass { $name:
    ensure   => $ensure,
    location => $location,
    url      => $url,
    vhost    => $vhost,
  }

  file { "/var/www/dev.camptocamp.org/private/dashboard-${name}.part":
    ensure  => $ensure,
    notify  => Exec["aggregate dashboard snippets"],
    content => "<li><a href='https://${vhost}${location}'>$name</a></li>\n",
  }

  if ($vhost == 'dev.camptocamp.org') {

    apache::auth::basic::file::user { "require password for $name access":
      ensure       => $ensure,
      location     => $location,
      vhost        => $vhost,
      authUserFile => $htpasswd,
    }

  } else {

    apache::vhost::ssl { $vhost:
      ensure    => $ensure,
      sslonly   => true,
      cert      => "file:///etc/puppet/dev.camptocamp.org.crt",
      certkey   => "file:///etc/puppet/dev.camptocamp.org.key",
      certchain => "file:///usr/share/ca-certificates/cacert.org/cacert.org.crt",
      require   => Package["ca-certificates"],
    }

    apache::auth::basic::file::user { "require password for $vhost access":
      ensure       => $ensure,
      location     => "/",
      vhost        => $vhost,
      authUserFile => $htpasswd,
    }

  }

}
