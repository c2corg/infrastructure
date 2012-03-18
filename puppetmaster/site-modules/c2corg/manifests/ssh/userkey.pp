define c2corg::ssh::userkey ($user, $account, $type, $key, $opts='') {

  include concat::setup

  $comment = "$user on $account"
  $sshopts = $opts ? {
    '' => '',
    default => "$opts ", # note ending whitespace
  }

  if (!defined(Concat["/etc/ssh/authorized_keys/${account}.keys"])) {
    concat { "/etc/ssh/authorized_keys/${account}.keys":
      owner => "root",
      group => "root",
      mode  => "0644",
    }
  }

  concat::fragment { "sshkey-for-${user}-on-${account}":
    target  => "/etc/ssh/authorized_keys/${account}.keys",
    content => "${sshopts}ssh-${type} ${key} ${comment}\n",
  }
}
