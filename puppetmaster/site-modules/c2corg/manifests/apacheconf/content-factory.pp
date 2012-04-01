class c2corg::apacheconf::content-factory inherits c2corg::apacheconf {

  include c2corg::password

  Apache::Vhost["camptocamp.org"] {
    aliases +> [$::hostname, $::fqdn, "${::hostname}.dev.camptocamp.org"],
  }

  apache::auth::htpasswd { "c2corg@camptocamp.org":
    vhost    => "camptocamp.org",
    username => "c2corg",
    cryptPassword => $c2corg::password::shared_crypt_pass,
  }

  apache::auth::basic::file::user { "require password for website access":
    location => "/",
    vhost    => "camptocamp.org",
  }

}
