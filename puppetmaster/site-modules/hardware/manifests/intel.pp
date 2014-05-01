class hardware::intel {

  package { ['intel-microcode', 'amd64-microcode', 'iucode-tool']:
    ensure => present,
  }

  # see http://lists.debian.org/debian-user/2013/09/msg00126.html
  apt::pin { 'backport_intel_microcode_updates':
    packages => 'intel-microcode amd64-microcode iucode-tool',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }
}
