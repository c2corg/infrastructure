# VM
node 'test-bubu' inherits 'base-node' {

  #$developer = "bubu"

  #realize C2corg::Account::User['bubu']
  #c2corg::account::user { "bubu@root": user => "bubu", account => "root" }

  #include c2corg::database::dev

  #include c2corg::webserver::symfony::dev
  #include c2corg::webserver::carto
  #include c2corg::webserver::svg

  #include c2corg::apacheconf::dev

  fact::register { 'role': value => 'dev' }

}
