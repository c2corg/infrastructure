# VM
node 'dev-cda' inherits 'base-node' {

  $developer = "easi"

  user { $developer:
    ensure     => present,
    shell      => "/bin/bash",
    managehome => true,
    groups     => ["adm", "www-data"],
  }

  c2corg::ssh::userkey { "Reynald Coupe on ${developer}":
    account => $developer,
    user    => "raynald.coupe@easi-services.fr",
    type    => "rsa",
    key     => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzT/ARSQm1yf2KYkIlPZrDQsp+D1qX5uk7Qe196P2DMTMIEQ2kIVHA+c942MW/6PXQwYDdxyT541N9v0CnzIiACUimAg+j3ATeJD8vbiOj8XOkqYMAknLArhDU+6HjH/TG9FAlLOBr1w88POxOMg0YFyeRkkLn/16EwhmT9K8IQZJpmugFUK7WYn7KfWdPDF+i0B1J6aLawkSnrAmk3gCJIHG4wtiZ+nNn5L0LY09NOeSL7H3Ml4jcY8Dnph6ohWgPS6RCltFxSYqXQ6/ychXlFQS71pN/GAw2ArMt+fooVPtfhh6XcAi2MeF/ev/GqmfhxNVhJePIyVFugLLUl1qLw==",
  }

  include c2corg::database::dev

  include c2corg::webserver::symfony::easi
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  realize C2corg::Account::User['gottferdom']

  fact::register { 'role': value => 'mandat dev CDA' }

  c2corg::backup::dir {
    ["/srv/www/camptocamp.org/"]:
  }

}
