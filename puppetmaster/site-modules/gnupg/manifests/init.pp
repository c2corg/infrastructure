class gnupg {

  package { "gnupg": ensure => present }

}

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

define gnupg::privkey (
  $user,
  $keytype='1',
  $keylength='1024',
  $realname='',
  $passphrase='',
  $expiry='0') {

  $template = template("gnupg/unattended-key-gen.erb")

  exec { "generate private key $name for $user":
    command   => "cat << EOF | su -c 'gpg --gen-key --batch' $user
$template
EOF",
    unless    => "su -c 'gpg --list-secret-keys $name' $user",
    logoutput => true,
    timeout   => 0,
  }

}

define gnupg::pubkey::file ($user, $ascii=true, $file) {

  if ($ascii == true) {
    $opt = "--armor"
  } else {
    $opt = ""
  }

  exec { "export key $name":
    command => "su -c 'gpg $opt --export $name > $file' $user",
    unless  => "test -e $file",
  }

}
