class app-vz-host {

  package { ["vzctl", "vzquota", "vzdump", "bridge-utils", "debootstrap"]:
    ensure => present,
  }

  apt::preferences { "openvz-kernel":
     package  => "linux-image-2.6.32-4-openvz-amd64",
     pin      => "release a=unstable",
     priority => "1010",
  }

  package { "linux-image-2.6.32-4-openvz-amd64":
    ensure  => present,
    require => Apt::Preferences["openvz-kernel"],
  }

  sysctl::set_value {
    "net.ipv4.ip_forward":                  value => "1";
    "net.ipv4.conf.default.proxy_arp":      value => "0";
    "net.ipv4.conf.all.rp_filter":          value => "1";
    "net.ipv4.conf.default.send_redirects": value => "1";
    "net.ipv4.conf.all.send_redirects":     value => "0";
  }

}
