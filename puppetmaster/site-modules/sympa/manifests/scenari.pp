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
