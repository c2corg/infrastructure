define c2corg::mailinglists::meteofrance($ensure='present', $listmaster, $hname) {

  $dept = $name

  sympa::list { "meteofrance-${dept}":
    ensure     => $ensure,
    send_from  => "meteofrance_slf",
    subject    => "Bulletins Nivo MeteoFrance ${dept}",
    anon_name  => "Bulletin Nivo MF ${dept}",
    listmaster => $listmaster,
    hname      => $hname,
  }

}
