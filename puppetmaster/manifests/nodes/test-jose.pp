# VM
node 'test-jose' inherits 'base-node' {

  $developer = "jose"

  realize C2corg::Account::User['jose']
  c2corg::account::user { "jose@root": user => "jose", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}
