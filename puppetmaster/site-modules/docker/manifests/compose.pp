class docker::compose {

  apt::pin { 'python_deps_from_c2corg_repo':
    packages => 'docker-compose python-docker python-dockerpty python-enum34 python-backports.ssl-match-hostname python-cached-property',
    label    => 'C2corg',
    priority => '1010',
  }

  apt::pin { 'python_deps_from_bpo':
    packages => 'python-requests python-urllib3 python-ipaddress',
    release  => 'jessie-backports',
    priority => '1010',
  }

  package { 'docker-compose': ensure => present }

}
