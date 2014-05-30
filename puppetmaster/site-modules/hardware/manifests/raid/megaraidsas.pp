class hardware::raid::megaraidsas {

  package { ['megacli', 'megactl', 'megaclisas-status']: }

  service { 'megaclisas-statusd':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "/usr/bin/daemon.*megaclisas-statusd.*megaclisas",
    require   => Package["megaclisas-status"],
  }

  $riemann_host = hiera('riemann_host')

  include riemann::client::python

  file { '/usr/local/sbin/megasas-riemann.py':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/hardware/megasas-riemann.py',
    require => [Package['megacli'], Class['riemann::client::python']],
  } ->

  cron { 'megasas-riemann':
    command => "/usr/bin/timeout -s 9 30 /usr/local/sbin/megasas-riemann.py ${riemann_host} 1440",
    minute  => '*/12',
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
