class c2cinfra::common::services {

  /* Base services */
  service { "cron":
    ensure => running, enable => true,
    require => Package["cron"],
  }

  service { "atd":
    ensure => running, enable => true,
    require => Package["at"],
  }

  package { "nscd": ensure => absent }

  if (str2bool($::is_virtual) == true) { $run_ntp = false }
  else { $run_ntp = true }

  service { "ntp":
    ensure => $run_ntp ? {
      false => stopped,
      true  => running,
    },
    enable => $run_ntp ? {
      false => false,
      true  => true,
    },
    hasstatus => true,
    require => Package["ntp"],
  }

  service { "sysstat":
    require => Package["sysstat"],
  }

  service { 'atop':
    ensure    => stopped,
    enable    => false,
    hasstatus => false,
    require   => Package['atop'],
  }

}
