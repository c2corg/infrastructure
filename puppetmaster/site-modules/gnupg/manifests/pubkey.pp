define gnupg::pubkey ($ensure="present", $user) {

  case $ensure {

    present: {
      exec { "import gpg key $name for $user":
        command => "su -c 'gpg --batch --keyserver pgp.mit.edu --recv-keys $name' $user",
        unless  => "su -c 'gpg --list-keys $name' $user",
        timeout => 0,
      }
    }

    absent: {
      exec { "delete gpg key $name for $user":
        command => "su -c 'gpg --batch --yes --delete-keys $name' $user",
        onlyif  => "su -c 'gpg --list-keys $name' $user",
      }
    }

  }
}
