define sympa::list ($ensure='present', $subject, $anon_name, $send_from, $footer='absent', $listmaster, $hname) {

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
    ensure  => $footer ? {
      'absent' => 'absent',
      default  => $ensure,
    },
    content => "\n-- \n${footer}",
  }

  mailalias { $name:
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/queue ${name}@${hname}",
    notify    => Exec["newaliases"],
  }

  mailalias { "${name}-owner":
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/bouncequeue ${name}@${hname}",
    notify    => Exec["newaliases"],
  }

}
