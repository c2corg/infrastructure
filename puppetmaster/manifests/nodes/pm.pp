# VM
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2cinfra::mcollective::client
  include buildenv::deb

  fact::register {
    'role': value => ['puppetmaster', 'config management'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir {
    ['/srv/infrastructure', '/var/lib/puppet/ssl', '/home', '/etc/puppet/hiera']:
  }

}
