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
