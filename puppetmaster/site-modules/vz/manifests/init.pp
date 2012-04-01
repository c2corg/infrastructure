class vz {

  include nat

  package { ["vzctl", "vzquota", "vzdump", "bridge-utils", "debootstrap"]:
    ensure => present,
  }

  package { "linux-image-2.6.32-5-openvz-amd64":
    ensure  => present,
  }

  sysctl::set_value {
    "net.ipv4.conf.default.forwarding":     value => "1";
    "net.ipv4.conf.all.forwarding":         value => "1";
    "net.ipv4.conf.default.proxy_arp":      value => "1";
    "net.ipv4.conf.all.proxy_arp":          value => "1";
    "net.ipv4.conf.all.rp_filter":          value => "1";
    "net.ipv4.conf.default.send_redirects": value => "1";
    "net.ipv4.conf.all.send_redirects":     value => "0";
  }

  service { "vz":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package["vzctl"],
  }

  file { [
    "/var/lib/vz",
    "/var/lib/vz/lock",
    "/var/lib/vz/private",
    "/var/lib/vz/template",
    "/var/lib/vz/template/cache",
    "/var/lib/vz/dump",
    "/var/lib/vz/root"]:
    ensure  => directory,
  }

  file { "/etc/vz/conf/ve-vps.unlimited.conf-sample":
    source  => "puppet:///modules/vz/ve-vps.unlimited.conf-sample",
    require => Package["vzctl"],
  }

  augeas { "compress vzctl logfiles":
    changes => "set /files/etc/logrotate.d/vzctl/rule/compress compress",
    require => Package["vzctl"],
  }

}
