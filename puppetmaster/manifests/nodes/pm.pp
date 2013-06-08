# VM
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2cinfra::mcollective::client
  include buildenv::deb

  file { '/etc/c2corg':
    ensure => absent,
    force  => true,
  }

  fact::register {
    'role': value => 'config management';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir {
    ['/srv/infrastructure', '/var/lib/puppet/ssl', '/home', '/etc/puppet/hiera']:
  }

}
