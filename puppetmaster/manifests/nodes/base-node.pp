# common template
node 'base-node' {

  include apt
  include augeas
  include openssl
  include puppet::hiera
  include c2cinfra::account
  include c2cinfra::mta
  include c2cinfra::ssh::sshd
  include "c2cinfra::apt::${::lsbdistcodename}"
  include c2cinfra::common::packages
  include c2cinfra::common::services
  include c2cinfra::common::config
  include c2cinfra::hosts
  include c2cinfra::syslog::client
  include c2cinfra::sudo # TODO: only if package sudo is installed
  include vz::facts

  if $::vagrant {
    realize C2cinfra::Account::User['vagrant']
  }
  else {
    include puppet::client
    include c2cinfra::mcollective::node

    sudoers { 'vagrant always has root access':
      users => 'vagrant',
      type  => "user_spec",
      commands => [ '(ALL) ALL' ],
    }
  }

  if $::lxc_type == 'container' {
    include lxc::guest
  }

  # Marc doesn't need to use root's account every time he must
  # manually run puppet.
  realize C2cinfra::Account::User['marc']

}
