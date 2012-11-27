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

  $ctname = $name
  $ctip = "${network}.${ctid}"
  $ctmacaddress = inline_template('00:FF:00:00:00:<%= ("%02x" % ctid).upcase %>')

  $rootpasswd = hiera('lxc_root_password')

  file { "/var/lib/lxc/${ctname}-preseed.cfg":
    ensure  => $ensure,
    content => template('lxc/preseed.cfg.erb'),
  }

  file { "/etc/lxc/auto/${name}":
    ensure => $ensure ? {
      'present' => $autostart ? {
        true    => link,
        default => absent,
      },
      default   => absent,
    },
    target => "/var/lib/lxc/${name}/config",
  }

  if ($ensure == 'present') {

    if ($fssize != false) {
      $fsopts = "-B lvm --lvname lxc${ctname} --vgname ${vgname} --fstype ${fstype} --fssize ${fssize}"
    }

    exec { "create container ${ctname}":
      command => "lxc-create -n ${ctname} -t debian ${fsopts} -- --preseed-file /var/lib/lxc/${ctname}-preseed.cfg",
      unless  => "test -e /var/lib/lxc/${ctname}",
      require => File["/var/lib/lxc/${ctname}-preseed.cfg"],
      timeout => 0,
    }

    if ($autostart == true) {
      exec { "start container ${ctname}":
        command => "lxc-start -n ${ctname} --daemon --quiet",
        unless  => "lxc-info -n ${ctname} --state | grep -q RUNNING",
        require => Exec["create container ${ctname}"],
      }
    }
  } else {

    exec { "destroy container ${ctname}":
      command => "lxc-destroy -f -n ${ctname}",
      onlyif  => "test -e /var/lib/lxc/${ctname}",
    }
  }

}
