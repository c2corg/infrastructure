# VM
node 'stats' inherits 'base-node' {

  realize C2cinfra::Account::User['saimon']

  include c2corg::stats

  fact::register {
    'role': value => 'service stats utilisateurs';
    'duty': value => 'prod';
  }

  sudoers { 'temporary root access for saimon':
    users    => 'saimon',
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

}
