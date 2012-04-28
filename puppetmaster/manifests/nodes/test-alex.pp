# VM
node 'test-alex' inherits 'base-node' {

  $developer = "alex"

  realize C2corg::Account::User[$developer]
  c2corg::account::user { "${developer}@root": user => $developer, account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

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
