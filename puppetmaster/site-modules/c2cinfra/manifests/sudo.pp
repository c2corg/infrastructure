class c2cinfra::sudo {

  resources { 'sudoers':
    purge => true,
  }

  $params = [
    '!authenticate',
    'env_reset',
    'env_keep="SSH_AUTH_SOCK"',
    'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
  ]

  sudoers { 'Defaults':
    parameters => $params,
    type => 'default',
  }

  sudoers { 'root all':
    users    => 'root',
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

}
