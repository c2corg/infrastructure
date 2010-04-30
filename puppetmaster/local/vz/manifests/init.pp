class vz {

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

  service { "vz":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package["vzctl"]
  }

  file { "/etc/vz/conf/ve-vps.unlimited.conf-sample":
    source  => "puppet:///vz/ve-vps.unlimited.conf-sample",
    require => Package["vzctl"],
  }

  iptables { "setup nat":
    table    => "nat",
    chain    => "POSTROUTING",
    outiface => "eth0.22",
    jump     => "MASQUERADE",
    require  => Sysctl::Set_value["net.ipv4.ip_forward"],
  }

}

define vz::ve ($ensure="running", $hname, $template="debian-5.0-amd64-with-puppet", $config="vps.unlimited", $net="192.168.191") {

  case $ensure {
    present,stopped,running: {

      exec { "vzctl create $name":
        command => "vzctl create $name --ostemplate $template --config $config --hostname $hname",
        creates => ["/etc/vz/conf/${name}.conf", "/var/lib/vz/private/${name}/"],
        require => Package["vzctl"],
      }

      exec { "configure VE $name":
        command => "vzctl set $name --name $hname --hostname $hname --ipadd ${net}.${name} --nameserver 8.8.8.8 --save",
        unless  => "egrep -q 'IP_ADDRESS=.?${net}.${name}.?' /etc/vz/names/${hname}",
        require => Exec["vzctl create $name"],
      }

      # start/stop VE
      case $ensure {
        running: {
          exec { "start VE $name":
            command => "vzctl start $name",
            onlyif  => "vzlist -a -H -o ctid,status | egrep '${name}\s+stopped'",
            require => Exec["configure VE $name"],
          }

          exec { "enable boottime start for $name":
            command => "vzctl set $name --onboot yes --save",
            onlyif  => "egrep -q 'ONBOOT=.?no.?' /etc/vz/names/${hname}",
            require => Exec["configure VE $name"],
          }
        }

        stopped: {
          exec { "stop VE $name":
            command => "vzctl stop $name",
            onlyif  => "vzlist -a -H -o ctid,status | egrep '${name}\s+running'",
            require => Exec["configure VE $name"],
          }

          exec { "disable boottime start for $name":
            command => "vzctl set $name --onboot no --save",
            onlyif  => "egrep -q 'ONBOOT=.?yes.?' /etc/vz/names/${hname}",
            require => Exec["configure VE $name"],
          }
        }
      }

    }

    absent: {
      exec { "vzctl destroy $name":
        command => "vzctl stop $name; vzctl destroy $name",
        onlyif  => "test -e /var/lib/vz/private/${name}",
      }

    }

  }
}
