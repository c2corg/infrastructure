class c2corg::mcollective {

  $broker = "192.168.192.55" #TODO: factorize this

  apt::preferences { "mcollective_from_wheezy_repo":
    package  => "mcollective mcollective-client mcollective-common",
    pin      => "release n=wheezy",
    priority => "1010",
  }

  package { "ruby-stomp": ensure => present }

  package {
    [
      'mcollective-plugins-filemgr',
      'mcollective-plugins-package',
      'mcollective-plugins-process',
      'mcollective-plugins-puppetd',
      'mcollective-plugins-stomputil',
      'mcollective-plugins-service',
    ]: ensure => present,
  }

}
