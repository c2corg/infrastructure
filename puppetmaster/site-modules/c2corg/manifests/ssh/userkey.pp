define c2corg::ssh::userkey ($user, $account, $type, $key, $opts='') {

  $comment = "$user on $account"
  $sshopts = $opts ? {
    '' => '',
    default => "$opts ", # note ending whitespace
  }

  common::concatfilepart { "sshkey-for-${user}-on-${account}":
    file    => "/etc/ssh/authorized_keys/${account}.keys",
    content => "${sshopts}ssh-${type} ${key} ${comment}\n",
    manage  => true,
  }
}
