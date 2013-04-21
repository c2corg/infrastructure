class sympa::mta($hname) inherits postfix {

  Postfix::Config["myorigin"] { value => $::fqdn }

  postfix::config {
    "myhostname":         value => $::fqdn;
    "mydestination":      value => "$::fqdn,$hname";
    "mynetworks":         value => "127.0.0.0/8";
    "virtual_alias_maps": value => "hash:/etc/postfix/virtual";
    "transport_maps":     value => "hash:/etc/postfix/transport";
    "relayhost":          value => "", ensure => absent;
  }

  postfix::hash { "/etc/postfix/virtual":
    ensure => present,
  }

  postfix::hash { "/etc/postfix/transport":
    ensure => present,
  }

}
