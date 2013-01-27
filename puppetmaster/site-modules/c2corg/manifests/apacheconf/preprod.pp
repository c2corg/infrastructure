class c2corg::apacheconf::preprod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections

  collectd::config::plugin { 'apache collectd config':
    plugin   => 'apache',
    settings => 'URL "http://localhost/server-status?auto"',
  }

  Apache::Vhost["camptocamp.org"] {
    aliases +> [
      "pre-prod.dev.camptocamp.org",
      "www.pre-prod.dev.camptocamp.org",
      "m.pre-prod.dev.camptocamp.org",
      "s.pre-prod.dev.camptocamp.org",
      ],
  }

  Apache::Vhost["meta.camptocamp.org"] {
    aliases +> ["meta.pre-prod.dev.camptocamp.org"],
  }
}
