class hardware::raid::megaraidsas {

  package { ['megacli', 'megactl', 'megaclisas-status']: }

  service { 'megaclisas-statusd':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/bin/daemon.*megaclisas-statusd.*megaclisas",
    require   => Package["megaclisas-status"],
  }

  # manually imported packages in local reprepro as upstream doesn't sign repo.
  # See: http://hwraid.le-vert.net/ticket/12

  #apt::source { 'megaraid':
  #  location => 'http://hwraid.le-vert.net/debian/',
  #  release  => "${::lsbdistcodename}",
  #  repos    => 'main',
  #}

  #apt::pin { 'megaraid':
  #  packages => '*',
  #  origin   => 'hwraid.le-vert.net',
  #  priority => '10',
  #}

}
