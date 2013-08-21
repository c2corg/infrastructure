class riemann {

  package { ['java7-runtime-headless', 'riemann', 'ruby-riemann-client']:
    ensure => present,
  } ->

  service { 'riemann':
    ensure    => present,
    enable    => true,
    hasstatus => true,
  }
}
