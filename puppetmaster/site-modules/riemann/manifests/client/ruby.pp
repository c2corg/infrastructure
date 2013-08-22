class riemann::client::ruby {

  package { ['ruby-riemann-client', 'ruby-beefcake']: ensure => present }
}
