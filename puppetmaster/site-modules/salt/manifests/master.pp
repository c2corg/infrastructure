class salt::master {

  include '::salt'

  package { 'salt-master': ensure => present } ->

  file { ['/etc/salt/pki/master/minions_pre/', '/etc/salt/pki/master/minions/']:
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
  } ->

  Exec <<| tag == 'saltstack' |>>
  File <<| tag == 'saltstack' |>>

}
