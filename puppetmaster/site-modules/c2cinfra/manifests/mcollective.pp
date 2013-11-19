class c2cinfra::mcollective {

  $broker = hiera('broker_host')

  apt::pin { 'mcollective_from_c2corg_repo':
    packages => 'mcollective mcollective-client mcollective-common ruby-stomp',
    label    => 'C2corg',
    priority => '1010',
  }

  package { "ruby-stomp": ensure => present }

  package { [
    'mcollective-filemgr-agent',
    'mcollective-package-agent',
    'mcollective-puppet-agent',
    'mcollective-service-agent',
    ]: ensure => present,
  }

}
