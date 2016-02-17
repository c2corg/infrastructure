# VM
node 'pm' {

  include c2cinfra::common
  realize C2cinfra::Account::User['xbrrr']

  include puppet::server
  include buildenv::deb

  service { 'salt-master':
    ensure => stopped,
  }

  fact::register {
    'role': value => ['puppetmaster', 'config management'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir {
    ['/srv/infrastructure', '/var/lib/puppet/ssl', '/home', '/etc/puppet/hiera']:
  }

}
