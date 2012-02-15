class memcachedb {

  package { "memcachedb": ensure => present }

  service { "memcachedb":
    ensure    => running,
    hasstatus => false,
    enable    => true,
    require   => Package["memcachedb"],
  }

  file { "/var/lib/memcachedb":
    ensure  => directory,
    owner   => "memcachedb",
    group   => "memcachedb",
    require => Package["memcachedb"],
    before  => Service["memcachedb"],
  }

  file { "/etc/memcachedb.conf":
    ensure  => present,
    source  => "puppet:///memcachedb/memcachedb.conf",
    notify  => Service["memcachedb"],
    require => Package["memcachedb"],
  }

}
