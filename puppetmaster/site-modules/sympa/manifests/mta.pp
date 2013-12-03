class sympa::mta($hname) {

  class { '::postfix':
    myorigin            => $::fqdn,
    mynetworks          => '127.0.0.0/8',
    mydestination       => "$::fqdn,$hname",
    smtp_listen         => '0.0.0.0',
    root_mail_recipient => hiera('root_mail_recipient'),
  }

  postfix::config {
    'myhostname':         value => $::fqdn;
    'virtual_alias_maps': value => 'hash:/etc/postfix/virtual';
    'transport_maps':     value => 'hash:/etc/postfix/transport';
    'relayhost':          value => '', ensure => absent;
  }

  postfix::hash { '/etc/postfix/virtual':
    ensure => present,
  }

  postfix::hash { '/etc/postfix/transport':
    ensure => present,
  }

}
