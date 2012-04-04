# VM
node 'test-xbrrr' inherits 'base-node' {

  $developer = "xbrrr"

  realize C2corg::Account::User['xbrrr']
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  fact::register { 'role': value => 'dev' }

}
