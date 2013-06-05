define lxc::container (
  $ensure='present',
  $autostart=true,
  $network='192.168.192',
  $vgname='vg0',
  $fstype='ext4',
  $fssize=false,
  $suite,
  $ctid,
) {

  require 'lxc::host'

  $ctfqdn = $name
  $ctname = inline_template('<%= name.split(".").first %>')
  $ctip = "${network}.${ctid}"
  $ctmacaddress = inline_template('00:FF:00:00:00:<%= ("%02x" % ctid).upcase %>')

  $rootpasswd = hiera('lxc_root_password')

  file { "/var/lib/lxc/${ctname}-preseed.cfg":
    ensure  => $ensure,
    content => template('lxc/preseed.cfg.erb'),
  }

  file { "/etc/lxc/auto/${ctname}":
    ensure => $ensure ? {
      'present' => $autostart ? {
        true    => link,
        default => absent,
      },
      default   => absent,
    },
    target => "/var/lib/lxc/${ctname}/config",
  }

  if ($ensure == 'present') {

    if ($fssize != false) {
      $fsopts = "-B lvm --lvname lxc${ctname} --vgname ${vgname} --fstype ${fstype} --fssize ${fssize}"

      logical_volume { "lxc${ctname}":
        ensure       => present,
        volume_group => "${vgname}",
        size         => "${fssize}",
        require      => Exec["create container ${ctname}"],
      }
    }

    exec { "create container ${ctname}":
      command => "lxc-create -n ${ctname} -t debian ${fsopts} -- --preseed-file /var/lib/lxc/${ctname}-preseed.cfg",
      unless  => "test -e /var/lib/lxc/${ctname}",
      require => File["/var/lib/lxc/${ctname}-preseed.cfg"],
      timeout => 0,
      logoutput => true,
    }

    if ($autostart == true) {
      exec { "start container ${ctname}":
        command => "lxc-start -n ${ctname} --daemon --quiet",
        unless  => "lxc-info -n ${ctname} --state | grep -q RUNNING",
        require => Exec["create container ${ctname}"],
      }
    }

    @@nat::fwd { "fwd LXC ${ctname} ssh port":
      host   => $ctid,
      from   => "10${ctid}",
      to     => 22,
      proto  => 'tcp',
      tag    => 'portfwd',
    }

    @@nat::fwd { "fwd LXC ${ctname} mosh port":
      host   => $ctid,
      from   => "60${ctid}",
      to     => "60${ctid}",
      proto  => 'udp',
      tag    => 'portfwd',
    }

  } else {

    exec { "destroy container ${ctname}":
      command => "lxc-destroy -f -n ${ctname}",
      onlyif  => "test -e /var/lib/lxc/${ctname}",
    }
  }


}
