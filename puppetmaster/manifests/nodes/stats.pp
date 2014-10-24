# VM
node 'stats' {

  include c2cinfra::common
  realize C2cinfra::Account::User['saimon']
  realize C2cinfra::Account::User['xbrrr']

  include c2corg::stats

  fact::register {
    'role': value => ['users stats'];
    'duty': value => 'prod';
  }

}
