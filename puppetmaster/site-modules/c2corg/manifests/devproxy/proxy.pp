define c2corg::devproxy::proxy($ensure='present', $host='', $aliases=[]) {

  apache::vhost { $name:
    aliases => $aliases,
    ensure  => $ensure
  } 

  apache::directive { "set ProxyPreserveHost for $name":
    ensure    => $ensure,
    vhost     => $name,
    directive => "ProxyPreserveHost on",
  }

  apache::proxypass { "set ProxyPass for $name":
    ensure    => $ensure,
    location  => "/",
    url       => "http://${host}/",
    vhost     => $name,
  }

}
