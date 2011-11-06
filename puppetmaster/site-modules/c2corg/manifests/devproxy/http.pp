class c2corg::devproxy::http {

  c2corg::devproxy::proxy { "pkg.dev.camptocamp.org":
    host => "pkg.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "content-factory.dev.camptocamp.org":
    host => "content-factory.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "pre-prod.dev.camptocamp.org":
    host => "pre-prod.psea.infra.camptocamp.org:8080",
    aliases => [
      "s.pre-prod.dev.camptocamp.org",
      "m.pre-prod.dev.camptocamp.org",
      "www.pre-prod.dev.camptocamp.org",
      "meta.pre-prod.dev.camptocamp.org",
    ],
  }

  c2corg::devproxy::proxy { "test-xbrrr.dev.camptocamp.org":
    host => "test-xbrrr.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-alex.dev.camptocamp.org":
    host => "test-alex.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-marc.dev.camptocamp.org":
    host => "test-marc.psea.infra.camptocamp.org",
  }

}
