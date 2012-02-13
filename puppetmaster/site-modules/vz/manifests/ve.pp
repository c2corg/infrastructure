define vz::ve ($ensure="running", $hname, $template="debian-squeeze-amd64-with-puppet", $config="vps.unlimited", $net="192.168.192") {

  $eth     = "eth0"
  $netmask = "255.255.255.0"
  $vethip  = "${net}.${name}"
  $gateway = "${net}.1"
  $dnssrv  = "8.8.8.8"
  $vethdev = "veth${name}.0"

  case $ensure {
    present,stopped,running: {

      exec { "vzctl create $name":
        command => "vzctl create $name --ostemplate $template --config $config --hostname $hname",
        creates => ["/etc/vz/names/${hname}", "/var/lib/vz/private/${name}/"],
        require => Package["vzctl"],
      }

      exec { "configure VE $name":
        command  => "vzctl set $name --name $hname --hostname $hname --netif_add $eth --nameserver $dnssrv --save",
        unless   => "egrep -q 'host_ifname=veth${name}' /etc/vz/names/${hname}",
        require  => Exec["vzctl create $name"],
      }

      file { "/etc/vz/conf/${name}.mount":
        mode    => 0755,
        content => template("vz/mount.erb"),
        before  => Exec["start VE $name"],
        require => Package["vzctl"],
      }

      file { "/var/lib/vz/private/${name}/etc/network/interfaces":
        content => template("vz/network.erb"),
        before  => Exec["start VE $name"],
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
            unless  => "egrep -q 'ONBOOT=.?yes.?' /etc/vz/names/${hname}",
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
