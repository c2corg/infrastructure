class salt::minion {

  include '::salt'

  package { ['salt-minion', 'python-augeas', 'python-git']: ensure => present } ->

  file { '/etc/salt/minion.d/':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['salt-minion'],
  } ->

  file { '/etc/salt/minion.d/minion.conf':
    ensure  => present,
    content => "# file managed by puppet
master: pm
id: ${::hostname}
extension_modules: opt/salt_ext
",
    notify  => Service['salt-minion'],
  } ->

  file { '/etc/salt/grains':
    ensure  => present,
    content => template('salt/grains.erb'),
    notify  => Service['salt-minion'],
  } ->

  file { '/opt/salt_ext':
    ensure  => directory,
    source  => 'puppet:///modules/salt/salt_ext',
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['salt-minion'],
  } ->

  file {
    '/etc/salt/pki/minion/minion.pem':
      ensure => link,
      target => "/var/lib/puppet/ssl/private_keys/${::hostname}.pem";
    '/etc/salt/pki/minion/minion.pub':
      ensure => link,
      target => "/var/lib/puppet/ssl/public_keys/${::hostname}.pem";
  } ~>

  service { 'salt-minion':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  @@exec { "authorize salt minion ${::hostname}":
    command => "openssl x509 -pubkey -noout -in /var/lib/puppet/ssl/ca/signed/${::hostname}.pem > /etc/salt/pki/master/minions/${::hostname}",
    creates => "/etc/salt/pki/master/minions/${::hostname}",
    tag     => 'saltstack',
  }

  @@file { "/etc/salt/pki/master/minions/${::hostname}":
    ensure  => present,
    require => Exec["authorize salt minion ${::hostname}"],
    tag     => 'saltstack',
  }

}
