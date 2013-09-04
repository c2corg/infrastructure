class hardware::intel {

  package { ['intel-microcode', 'amd64-microcode', 'iucode-tool']:
    ensure => present,
  }

  # see http://lists.debian.org/debian-user/2013/09/msg00126.html
  apt::preferences { 'backport intel microcode updates':
    package  => 'intel-microcode amd64-microcode iucode-tool',
    pin      => "release a=${::lsbdistcodename}-backports",
    priority => '1010',
  }
}
