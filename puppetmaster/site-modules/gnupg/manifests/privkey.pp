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
