# VM
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2corg::mcollective::client
  include c2cinfra::collectd::node
  include buildenv::deb

  file { '/etc/c2corg':
    ensure => absent,
    force  => true,
  }

  fact::register {
    'role': value => 'config management';
    'duty': value => 'prod';
  }

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home", "/etc/puppet/hiera"]:
  }

}
