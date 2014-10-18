class c2corg::apacheconf::preprod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections

  collectd::config::plugin { 'apache collectd config':
    plugin   => 'apache',
    settings => '
<Instance "preprod">
  URL "http://localhost/server-status?auto"
</Instance>
',
  }

  Apache::Vhost["camptocamp.org"] {
    aliases +> [
      $::hostname,
      "www.${::hostname}",
      "s.${::hostname}",
      $::fqdn,
      "pre-prod.dev.camptocamp.org",
      "www.pre-prod.dev.camptocamp.org",
      "s.pre-prod.dev.camptocamp.org",
    ],
  }

  Apache::Vhost["meta.camptocamp.org"] {
    aliases +> ["meta.pre-prod.dev.camptocamp.org"],
  }
}
