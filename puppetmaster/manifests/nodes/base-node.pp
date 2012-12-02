# common template
node 'base-node' {

  include apt
  include augeas
  include openssl
  include puppet::hiera
  include c2cinfra::account
  include c2corg::mta
  include c2cinfra::ssh::sshd
  include "c2corg::apt::${::lsbdistcodename}"
  include c2corg::common::packages
  include c2corg::common::services
  include c2corg::common::config
  include c2corg::hosts
  include c2corg::syslog::client
  include c2corg::sudo # TODO: only if package sudo is installed
  include vz::facts

  if $::vagrant {
    realize C2cinfra::Account::User['vagrant']
  }
  else {
    include puppet::client
    include c2corg::mcollective::node
  }

  # Marc doesn't need to use root's account every time he must
  # manually run puppet.
  realize C2cinfra::Account::User['marc']

}
