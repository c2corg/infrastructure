node 'vagrant-sandbox' {

  include c2cinfra::common
  # Uncomment the following section to setup a symfony web + postgresql
  # database environment.
  #
  # class { 'c2corg::dev::env::symfony':
  #   developer => 'vagrant',
  # }

}
