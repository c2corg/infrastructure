class c2corg::devproxy::http {

  c2corg::devproxy::proxy { "pkg.dev.camptocamp.org":
    host => "pkg.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "content-factory.dev.camptocamp.org":
    host => "content-factory.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "pre-prod.dev.camptocamp.org":
    host => "pre-prod.pse.infra.camptocamp.org:8080",
    aliases => [
      "s.pre-prod.dev.camptocamp.org",
      "m.pre-prod.dev.camptocamp.org",
      "www.pre-prod.dev.camptocamp.org",
      "meta.pre-prod.dev.camptocamp.org",
    ],
  }

  C2corg::Devproxy::Proxy <| |>

  @@nat::fwd { 'forward http port':
    host  => '103',
    from  => '80',
    to    => '80',
    proto => 'tcp',
    tag   => 'portfwd',
  }

}
