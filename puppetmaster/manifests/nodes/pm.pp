# VM
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2corg::mcollective::client
  include c2corg::collectd::node

  # TODO: mv this stuff to a decent backend system
  file { "/etc/c2corg":
    ensure => directory,
    owner  => "marc",
  }

  fact::register {
    'role': value => 'config management';
    'duty': value => 'prod';
  }

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home", "/etc/c2corg"]:
  }

}
