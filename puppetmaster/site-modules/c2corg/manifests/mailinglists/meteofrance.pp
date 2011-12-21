define c2corg::mailinglists::meteofrance($ensure='present') {

  $dept = $name

  sympa::list { "meteofrance-${dept}":
    ensure    => $ensure,
    send_from => "meteofrance",
    subject   => "Bulletins Nivo MeteoFrance ${dept}",
    anon_name => "Bulletin Nivo MF ${dept}",
  }

}
