class c2corg::webserver {

  include apache
  include php::apache

  augeas { "dont expose PHP version":
    changes => "set /files/etc/php5/apache2/php.ini/PHP/expose_php Off",
    notify  => Service["apache"],
  }

  package { "apachetop": }


  sudoers { 'restart apache':
    users => 'c2corg',
    type  => "user_spec",
    commands => [
      '(root) /etc/init.d/apache2',
      '(root) /usr/sbin/invoke-rc.d apache2 *',
      '(root) /usr/sbin/apachectl',
      '(root) /usr/sbin/apache2ctl',
    ],
  }

  sudoers { 'do as www-data':
    users => '%www-data',
    type  => "user_spec",
    commands => [ '(www-data) ALL' ],
  }

}
