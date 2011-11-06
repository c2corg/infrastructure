class c2corg::common::services {

  /* Base services */
  service { "cron":
    ensure => running, enable => true,
    require => Package["cron"],
  }

  service { "atd":
    ensure => running, enable => true,
    require => Package["at"],
  }

  service { "nscd":
    ensure => running, enable => true, hasstatus => true,
    require => Package["nscd"],
  }

  service { "ntp":
    ensure => $is_virtual ? {
      'true'  => stopped,
      'false' => running,
    },
    enable => $is_virtual ? {
      'true'  => false,
      'false' => true,
    },
    hasstatus => true,
    require => Package["ntp"],
  }

  service { "sysstat":
    require => Package["sysstat"],
  }

}
