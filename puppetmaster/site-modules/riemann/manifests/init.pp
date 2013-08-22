class riemann {

  package { ['java7-runtime-headless', 'riemann']:
    ensure => present,
  } ->

  service { 'riemann':
    ensure    => present,
    enable    => true,
    hasstatus => true,
  }
}
