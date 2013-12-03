class c2cinfra::mta {

  if ($::hostname != 'lists') {
    class { '::postfix':
      root_mail_recipient => hiera('root_mail_recipient'),
      relayhost           => 'googlemail.com',
    }
    class { '::postfix::satellite': }
  }

  postfix::config { 'smtp_tls_CAfile':
    value   => '/etc/ssl/certs/ca-certificates.crt',
    require => File['ca-certificates.crt'],
  }

}
