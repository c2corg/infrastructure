class c2corg::reprepro {

  $reprepro_basedir = "/srv/deb-repo"
  include reprepro

  # allowed uploader(s)
  account::user { "marc@reprepro":
    user    => "marc",
    account => "reprepro",
  }

  # reprepro only validates packages signed by known keys.
  gnupg::pubkey { "4DA7C546":
    user => "reprepro",
  }

  # generate a passwordless GPG key...
  gnupg::privkey { "pkgs@c2corg":
    user => "reprepro",
    realname => "c2corg Package Archive Key",
  }

  # ...and publish the public part.
  gnupg::pubkey::file { "pkgs@c2corg":
    user => "reprepro",
    file => "${reprepro_basedir}/pubkey.txt",
  }

  /* configure the repository managment tool */

  reprepro::repository { "test": incoming_allow => "lenny squeeze" }
  reprepro::repository { "prod": # no incoming, just feed on test repo }

  Reprepro::Distribution {
    origin        => "C2corg",
    label         => "C2corg",
    architectures => "i386 amd64 kfreebsd-amd64 source",
    components    => "main",
    sign_with     => "pkgs@c2corg",
  }

  reprepro::distribution { "squeeze-test":
    repository  => "test",
    codename    => "squeeze",
    suite       => "squeeze",
    description => "c2corg squeeze test repository",
  }

  reprepro::distribution { "lenny-test":
    repository  => "test",
    codename    => "lenny",
    suite       => "lenny",
    description => "c2corg lenny test repository",
  }


  reprepro::update { ["test2prod-squeeze", "test2prod-lenny"]:
    repository  => "prod", url => "http://localhost/test",
  }

  reprepro::distribution { "squeeze-prod":
    repository  => "prod",
    codename    => "squeeze",
    suite       => "squeeze",
    description => "c2corg squeeze production repository",
    update      => "test2prod-squeeze",
  }

  reprepro::distribution { "lenny-prod":
    repository  => "prod",
    codename    => "lenny",
    suite       => "lenny",
    description => "c2corg lenny production repository",
    update      => "test2prod-lenny",
  }


  /* setup a mini-webserver to publish all this stuff. */

  include thttpd

  file { "/etc/thttpd/thttpd.conf":
    ensure  => present,
    content => "# file managed by puppet
user=www-data
chroot
dir=$reprepro_basedir
port=80
",
    require => Package["thttpd"],
    notify  => Service["thttpd"],
  }

}
