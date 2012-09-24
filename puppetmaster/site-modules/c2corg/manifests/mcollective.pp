class c2corg::mcollective {

  $broker = hiera('broker_host')

  apt::preferences { "mcollective_from_c2corg_repo":
    package  => "mcollective mcollective-client mcollective-common ruby-stomp",
    pin      => "release l=C2corg",
    priority => "1010",
  }

  package { "ruby-stomp": ensure => present }

  #package {
  #  [
  #    'mcollective-plugins-filemgr',
  #    'mcollective-plugins-package',
  #    'mcollective-plugins-process',
  #    'mcollective-plugins-puppetd',
  #    'mcollective-plugins-stomputil',
  #    'mcollective-plugins-service',
  #  ]: ensure => present,
  #}

}
