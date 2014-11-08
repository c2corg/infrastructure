class c2corg::mailinglists {

  include c2cinfra::collectd::plugin::postfix

  $listmaster = 'listmaster@camptocamp.org'
  $hname      = 'lists.camptocamp.org'

  class { 'sympa':
    dbhost     => hiera('db_host'),
    dbport     => hiera('db_port'),
    dbtype     => 'Pg',
    dbname     => 'c2corg',
    dbuser     => hiera('ml_db_user'),
    dbpwd      => hiera('ml_db_pass'),
    hname      => $hname,
    listmaster => $listmaster,
  }

  class { 'sympa::mta':
    hname => $hname,
  }

  @@nat::fwd { '001 forward smtp port':
    host  => '102',
    from  => '25',
    to    => '25',
    proto => 'tcp',
    tag   => 'portfwd',
  }

  sympa::scenari { "marc":
    ensure  => absent, # enable for tests
    content => '
match([sender],/^marc.fournier@camptocamp.org$/)     smtp              -> do_it
true()                                               smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "slf":
    ensure => absent,
    content => '
match([sender],/@slf\.ch$/)         smtp              -> do_it
true()                              smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "meteofrance":
    ensure => absent,
    content => '
match([sender],/nobody@lists.*\.camptocamp\.org$/)    smtp              -> do_it
true()                                          smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "meteofrance_slf":
    content => '
match([sender],/nobody@lists.*\.camptocamp\.org$/)    smtp              -> do_it
true()                                          smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "aran":
    content => '
match([sender],/@aran\.org$/)       smtp              -> do_it
true()                              smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "catalunya":
    content => '
match([sender],/@igc\.cat$/)       smtp              -> do_it
true()                             smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "everybody":
    content => '
match([sender],/^.*$/)     smtp             -> do_it
true()                     smtp,smime,md5   -> reject
',
  }

  sympa::list { "aran":
    send_from  => "aran",
    subject    => "Boletin de lauegi",
    anon_name  => "Centre de Lauegi d'Aran",
    listmaster => $listmaster,
    hname      => $hname,
  }

  sympa::list { "catalunya":
    send_from  => "catalunya",
    subject    => "Prediccio d'Allaus",
    anon_name  => "Institut Geologic de Catalunya",
    listmaster => $listmaster,
    hname      => $hname,
  }

  c2corg::mailinglists::meteofrance {[
    '04','05','06','09','2a','2b','31','38','64','65','66','73','74','andorre']:
    listmaster => $listmaster,
    hname      => $hname,
  }

  sympa::list { "avalanche":
    send_from  => "meteofrance_slf",
    subject    => "bulletin avalanche SLF",
    anon_name  => "Bulletin SLF",
    listmaster => $listmaster,
    hname      => $hname,
  }

  sympa::list { "avalanche.en":
    send_from  => "meteofrance_slf",
    subject    => "avalanche bulletin SLF",
    anon_name  => "SLF bulletin",
    listmaster => $listmaster,
    hname      => $hname,
  }

  sympa::list { "lawinen":
    send_from  => "meteofrance_slf",
    subject    => "Lawinenbulletin SLF",
    anon_name  => "Lawinenbulletin SLF",
    listmaster => $listmaster,
    hname      => $hname,
  }

  sympa::list { "valanghe":
    send_from  => "meteofrance_slf",
    subject    => "bollettino valanghe SLF",
    anon_name  => "Bollettino SLF",
    listmaster => $listmaster,
    hname      => $hname,
  }

}
