class c2corg::apacheconf::dev inherits c2corg::apacheconf {

  Apache::Vhost["camptocamp.org"] {
    aliases +> [
      $::hostname,
      $::fqdn,
      "${::hostname}.dev.camptocamp.org",
      '127.127.127.127',
    ],
  }
}
