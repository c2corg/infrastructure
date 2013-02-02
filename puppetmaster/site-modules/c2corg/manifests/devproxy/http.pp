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

  c2corg::devproxy::proxy { "test-xbrrr.dev.camptocamp.org":
    host => "test-xbrrr.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-alex.dev.camptocamp.org":
    host => "test-alex.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-marc.dev.camptocamp.org":
    host => "test-marc.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-jose.dev.camptocamp.org":
    host => "test-jose.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-bubu.dev.camptocamp.org":
    host => "test-bubu.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-saimon.dev.camptocamp.org":
    host => "test-saimon.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-gottferdom.dev.camptocamp.org":
    host => "test-gottferdom.pse.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "dev-cda.dev.camptocamp.org":
    host => "dev-cda.pse.infra.camptocamp.org",
  }

  @@nat::fwd { 'forward http port':
    host  => '103',
    from  => '80',
    to    => '80',
    proto => 'tcp',
    tag   => 'portfwd',
  }

}
