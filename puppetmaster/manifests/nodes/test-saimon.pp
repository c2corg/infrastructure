# VM
node 'test-saimon' inherits 'base-node' {

  $developer = "saimon"

  realize C2corg::Account::User[$developer]
  c2corg::account::user { "${developer}@root": user => $developer, account => "root" }

  sudoers { "root access for ${developer}":
    users    => $developer,
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

}
