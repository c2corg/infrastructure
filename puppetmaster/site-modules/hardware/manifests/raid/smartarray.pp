class hardware::raid::smartarray {

  package { ["cpqarrayd", "arrayprobe", "cciss-vol-status"]:
    ensure => present,
  }

  service { "cpqarrayd":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/sbin/cpqarrayd",
    require   => Package["cpqarrayd"],
  }

}
