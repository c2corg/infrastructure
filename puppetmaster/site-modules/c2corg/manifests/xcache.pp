class c2corg::xcache {

  package { "php5-xcache":
    ensure => present,
  }

  augeas { "disable php-xcache admin auth":
    changes => "set /files/etc/php5/conf.d/xcache.ini/xcache.admin/xcache.admin.enable_auth Off",
    require => Package["php5-xcache"],
  }

  file { "xcachestats.php":
    ensure => present,
    path   => "/var/www/html/xcachestats.php",
    source => "puppet:///c2corg/xcache/xcachestats.php",
  }

  file { "/etc/apache2/conf.d/xcachestats.conf":
    ensure => present,
    content => "# file managed by puppet
<Location /xcachestats.php>
  Order deny,allow
  Deny from all
  Allow from localhost ip6-localhost 127.0.0.0/255.0.0.0
</Location>
",
    notify  => Exec["apache-graceful"],
  }

  collectd::plugin { "xcachestats":
    require => [File["/etc/apache2/conf.d/xcachestats.conf"], File["xcachestats.php"]],
    content => '# file managed by puppet
LoadPlugin "curl_json"
<Plugin curl_json>
  <URL "http://localhost/xcachestats.php?0">
    Instance "xcache"
    <Key "slots">
      Type "bytes"
    </Key>
    #<Key "compiling">
    #  Type ""
    #</Key>
    <Key "misses">
      Type "connections"
    </Key>
    <Key "hits">
      Type "connections"
    </Key>
    <Key "clogs">
      Type "connections"
    </Key>
    <Key "ooms">
      Type "connections"
    </Key>
    <Key "errors">
      Type "connections"
    </Key>
    <Key "cached">
      Type "connections"
    </Key>
    <Key "deleted">
      Type "connections"
    </Key>
    #<Key "gc">
    #  Type ""
    #</Key>
    <Key "size">
      Type "bytes"
    </Key>
    <Key "avail">
      Type "bytes"
    </Key>
  </URL>
</Plugin>
',
  }

}
