class c2cinfra::hosts {

  resources { "host":
    purge => true,
  }

  $subnet = $::hostname ? {
    'backup'    => 'ghst',
    'ipv6proxy' => 'ghst',
    'backup0'   => 'ovh',
    /^docker.*/ => 'exoscale',
    /^datamigration.*/ => 'exoscale',
    default     => 'pse',
  }

  host { "${::hostname}.${subnet}.infra.camptocamp.org":
    ip => $::hostname ? {
      "hn0"   => "192.168.192.1",
      "hn2"   => "192.168.192.3",
      "hn3"   => "192.168.192.4",
      "hn4"   => "192.168.192.5",
      default => $::ipaddress,
    },
    host_aliases => $::hostname,
  }

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
