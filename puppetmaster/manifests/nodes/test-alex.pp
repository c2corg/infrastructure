# VM
node 'test-alex' inherits 'base-node' {

  $developer = "alex"

  realize C2corg::Account::User['alex']
  c2corg::account::user { "alex@root": user => "alex", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  fact::register { 'role': value => 'dev' }

}
