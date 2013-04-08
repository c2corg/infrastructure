class c2corg::dev::env::plain ($developer, $rootaccess=true) {

  realize C2cinfra::Account::User[$developer]

  if $rootaccess == true {
    c2cinfra::account::user { "${developer}@root": user => $developer, account => "root" }
  }

  sudoers { "root access for ${developer}":
    users    => $developer,
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

  @@c2corg::devproxy::proxy { "${::hostname}.dev.camptocamp.org":
    host    => "${::hostname}.pse.infra.camptocamp.org",
  }
}
