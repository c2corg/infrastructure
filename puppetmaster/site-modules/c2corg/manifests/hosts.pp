class c2corg::hosts {

  resources { "host":
    purge => true,
  }

  if ($fqdn != "pm.c2corg") {
  # pm.c2corg is handled in puppet::client
    @@host { "$fqdn":
      ip => $ipaddress,
      host_aliases => $hostname,
      tag => 'poor-man-dns'
    }
  }
  Host <<| tag == 'poor-man-dns' |>>

  host { "localhost.localdomain":
    ip => "127.0.0.1",
    host_aliases => "localhost",
  }

  host { "ip6-localhost":
    ip => "::1",
    host_aliases => "ip6-loopback",
  }

  host { "ip6-localnet": ip => "fe00::0" }
  host { "ip6-mcastprefix": ip => "ff00::0" }
  host { "ip6-allnodes": ip => "ff02::1" }
  host { "ip6-allrouters": ip => "ff02::2" }
  host { "ip6-allhosts": ip => "ff02::3" }

}
