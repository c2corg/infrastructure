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

  @@nat::fwd { '001 forward salt master port':
    host  => '101',
    from  => '4505',
    to    => '4505',
    proto => 'tcp',
    tag   => 'portfwd',
  }

  @@nat::fwd { '002 forward salt master port':
    host  => '101',
    from  => '4506',
    to    => '4506',
    proto => 'tcp',
    tag   => 'portfwd',
  }


}
