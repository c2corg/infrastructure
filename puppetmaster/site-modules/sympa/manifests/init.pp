class sympa {

  apt::preferences { "sympa_from_c2corg_repo":
    package  => "sympa",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
    before   => Package["sympa"],
  }


  package { 'sympa':
    ensure => present,
  }

  file { "/etc/sympa/sympa.conf":
    ensure  => present,
    content => template("sympa/sympa.conf.erb"),
    require => Package["sympa"],
    notify  => Service["sympa"],
  }

  service { 'sympa':
    ensure  => running,
    enable  => true,
    require => File["/etc/sympa/sympa.conf"],
  }

}

class sympa::mta inherits postfix {

  Postfix::Config["myorigin"] { value => $hname }

  postfix::config {
    "myhostname":         value => $fqdn;
    "mydestination":      value => "\$myorigin";
    "mynetworks":         value => "127.0.0.0/8";
    "virtual_alias_maps": value => "hash:/etc/postfix/virtual";
    "transport_maps":     value => "hash:/etc/postfix/transport";
    "relayhost":          value => "", ensure => absent;
  }

  postfix::hash { "/etc/postfix/virtual":
    ensure => present,
  }

  postfix::hash { "/etc/postfix/transport":
    ensure => present,
  }

}

define sympa::list ($ensure='present', $subject, $anon_name, $send_from, $footer) {

  File {
    ensure => $ensure,
    owner  => "sympa",
    group  => "sympa",
    mode   => 0640,
  }

  file { "/var/lib/sympa/expl/${name}":
    ensure  => $ensure ? {
      'present' => 'directory',
      default   => $ensure,
    },
    require => Package["sympa"],
  }

  file { [
    "/var/lib/sympa/expl/${name}/subscribers",
    "/var/lib/sympa/expl/${name}/stats",
    "/var/lib/sympa/expl/${name}/msg_count",
    ]:
  }

  file { "/var/lib/sympa/expl/${name}/config":
    content => template("sympa/config.erb"),
    require => Sympa::Scenari[$send_from],
    before  => [Mailalias[$name], Mailalias["${name}-owner"]],
  }

  file { "/var/lib/sympa/expl/${name}/message.footer":
    content => "\n-- \n${footer}",
  }

  mailalias { $name:
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/queue ${name}@${hname}",
  }

  mailalias { "${name}-owner":
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/bouncequeue ${name}@${hname}",
  }

}

define sympa::scenari ($ensure='present', $content) {

  file { "/etc/sympa/scenari/send.${name}":
    ensure  => $ensure,
    require => Package["sympa"],
    notify  => Service["sympa"],
    content => "title.gettext scenari ${name}

${content}
",
  }

}
