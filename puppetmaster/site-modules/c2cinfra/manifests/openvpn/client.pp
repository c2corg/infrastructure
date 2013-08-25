class c2cinfra::openvpn::client ($username, $password) {

  class { '::c2cinfra::openvpn': }

  File {
    ensure  => present,
    mode    => '0600',
    notify  => Service['openvpn'],
    require => Package['openvpn'],
  }

  file {
    '/etc/openvpn/c2corg.conf':
      source => 'puppet:///modules/c2cinfra/openvpn/client.conf';
    '/etc/openvpn/ca.crt':
      source => 'puppet:///modules/c2cinfra/openvpn/keys/ca.crt';
    '/etc/openvpn/ta.key':
      source => 'puppet:///modules/c2cinfra/openvpn/keys/ta.key';
    '/etc/openvpn/up.txt':
      content => "${username}\n${password}\n";
  }

}
