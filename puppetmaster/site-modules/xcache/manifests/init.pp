class xcache {

  package { 'php5-xcache':
    ensure => present,
  }

  xcache::param { 'xcache.admin/xcache.admin.enable_auth': value => 'Off' }

  file { 'xcachestats.php':
    ensure => present,
    path   => '/var/www/html/xcachestats.php',
    source => 'puppet:///modules/xcache/xcachestats.php',
  }

  file { '/etc/apache2/conf.d/xcachestats.conf':
    ensure => present,
    content => "# file managed by puppet
<Location /xcachestats.php>
  Order deny,allow
  Deny from all
  Allow from localhost ip6-localhost 127.0.0.0/255.0.0.0
</Location>
",
    notify  => Exec['apache-graceful'],
  }

  collectd::config::plugin { 'xcachestats':
    require  => [File['/etc/apache2/conf.d/xcachestats.conf'], File['xcachestats.php']],
    plugin   => 'curl_json',
    settings => '
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
',
  }

}
