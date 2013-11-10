# common template
node 'base-node' {

  include apt
  include augeas
  include openssl
  include puppet::hiera
  include c2cinfra::account
  include c2cinfra::mta
  include c2cinfra::ssh::sshd
  include c2cinfra::common::packages
  include c2cinfra::common::services
  include c2cinfra::common::config
  include c2cinfra::hosts
  include c2cinfra::syslog::client
  include c2cinfra::sudo # TODO: only if package sudo is installed
  include vz::facts

  # workaround for broken LSB facts
  if $::lsbdistcodename == 'n/a' {

    $pkgrepo = hiera('pkgrepo_host')
    apt::sources_list { "c2corg":
      content => "# file managed by puppet
deb http://${pkgrepo}/c2corg/ wheezy main
  ",
    } ->

    apt::sources_list { 'debian':
      content => '# file managed by puppet
deb http://http.debian.net/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://http.debian.net/debian/ wheezy-proposed-updates main contrib non-free
',
    } ->

    # see debbug#711174
    apt::preferences { 'force working version of base-files':
      package  => 'base-files',
      pin      => 'release l=C2corg, a=wheezy',
      priority => '1100',
    } ->

    exec { 'apt-get -y --force-yes install base-files':
      require => Exec['apt-get_update'],
    }

  } else {
    include "c2cinfra::apt::${::lsbdistcodename}"
  }

  if str2bool($::vagrant) {
    realize C2cinfra::Account::User['vagrant']

    sudoers { 'vagrant always has root access':
      users => 'vagrant',
      type  => "user_spec",
      commands => [ '(ALL) ALL' ],
    }
  }
  else {
    include puppet::client
    include c2cinfra::mcollective::node
    include c2cinfra::collectd::node
  }

  if $::lxc_type == 'container' {
    include lxc::guest
  }

  if $::duty {
    c2cinfra::metrics::alias { "by-duty/${::duty}/${::hostname}":
      target => "collectd/${::hostname}",
    }
  }

  # Marc doesn't need to use root's account every time he must
  # manually run puppet.
  realize C2cinfra::Account::User['marc']

}
