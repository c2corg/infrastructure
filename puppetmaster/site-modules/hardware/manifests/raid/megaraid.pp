class hardware::raid::megaraid {

  package { ["dellmgr", "megactl", "megaraid-status"]: }

  service { "megaraid-statusd":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/bin/daemon.*megaraid-statusd.*check_megaraid",
    require   => Package["megaraid-status"],
  }

}
