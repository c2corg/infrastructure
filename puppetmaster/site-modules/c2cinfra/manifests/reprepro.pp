class c2cinfra::reprepro {

  include reprepro::debian

  $reprepro_basedir = '/var/packages'

  file { "${reprepro_basedir}/.ssh/":
    ensure => directory,
    owner  => "reprepro",
    group  => "reprepro",
  }

  # allowed uploader(s)
  c2cinfra::account::user { "marc@reprepro":
    user    => "marc",
    account => "reprepro",
    require => File[$reprepro_basedir],
  }

  # reprepro only validates packages signed by known keys.
  gnupg::pubkey { "4DA7C546":
    user    => "reprepro",
    require => [User["reprepro"], File[$reprepro_basedir]],
  }

  # generate a passwordless GPG key...
  gnupg::privkey { "pkgs@c2corg":
    user     => "reprepro",
    realname => "c2corg Package Archive Key",
    require  => [User["reprepro"], File[$reprepro_basedir]],
  }

  # ...and publish the public part.
  gnupg::pubkey::file { "pkgs@c2corg":
    user     => "reprepro",
    file     => "${reprepro_basedir}/pubkey.txt",
    require  => [User["reprepro"], File[$reprepro_basedir]],
  }

  /* configure the repository managment tool */

  reprepro::repository { "c2corg": incoming_allow => "squeeze wheezy" }

  Reprepro::Distribution {
    origin        => "C2corg",
    label         => "C2corg",
    architectures => "i386 amd64 source",
    components    => "main",
    sign_with     => "pkgs@c2corg",
  }

  reprepro::distribution { "jessie-c2corg":
    repository  => "c2corg",
    codename    => "jessie",
    suite       => "jessie",
    description => "c2corg jessie repository",
  }

  reprepro::distribution { "wheezy-c2corg":
    repository  => "c2corg",
    codename    => "wheezy",
    suite       => "wheezy",
    description => "c2corg wheezy repository",
  }

  reprepro::distribution { "squeeze-c2corg":
    repository  => "c2corg",
    codename    => "squeeze",
    suite       => "squeeze",
    description => "c2corg squeeze repository",
  }

  /* setup a mini-webserver to publish all this stuff. */

  class { 'nginx': package => 'nginx-light' }

  nginx::site { 'pkg':
    require => File[$reprepro_basedir],
    content => "# file managed by puppet
server {
  listen 80 default_server;
  server_name pkg.dev.camptocamp.org;

  location / {
    root ${reprepro_basedir};
    autoindex on;
  }
}
",
  }

  file { "${reprepro_basedir}/install-puppet.sh":
    ensure => present,
    source => 'puppet:///modules/puppet/install-puppet.sh',
  }

  package { 'thttpd': ensure => absent } ->
  file { '/etc/thttpd/thttpd.conf': ensure => absent }

}
