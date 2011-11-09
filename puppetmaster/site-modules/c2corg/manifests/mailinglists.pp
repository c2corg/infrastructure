class c2corg::mailinglists {

  include c2corg::password
  include c2corg::mta # just import attributes

  $dbhost = '192.168.192.5' #TODO: factorize
  $dbport = '5432'
  $dbtype = 'Pg'
  $dbname = 'c2corg'
  $dbuser = $c2corg::password::ml_db_user
  $dbpwd  = $c2corg::password::ml_db_pass
  $hname  = 'lists.camptocamp.org'
  $listmaster = 'listmaster@camptocamp.org'

  $postfix_smtp_listen = "0.0.0.0"
  $root_mail_recipient = $c2corg::mta::root_mail_recipient

  include sympa
  include sympa::mta

  sympa::scenari { "marc":
    ensure  => absent, # enable for tests
    content => "
match([sender],/^marc.fournier@camptocamp.org$/)     smtp              -> do_it
true()                                               smtp,smime,md5    -> reject
",
  }

  sympa::scenari { "slf":
    content => "
match([sender],/@slf\.ch$/)         smtp              -> do_it
true()                              smtp,smime,md5    -> reject
",
  }

  sympa::scenari { "meteofrance":
    content => "
match([sender],/@lists.*\.camptocamp\.org$/)    smtp              -> do_it
true()                                          smtp,smime,md5    -> reject
",
  }

  sympa::scenari { "everybody":
    content => "
match([sender],/^.*$/)     smtp             -> do_it
true()                     smtp,smime,md5   -> reject
",
  }

  sympa::list { "avalanche":
    send_from => "slf",
    subject   => "bulletin avalanche ENA",
    anon_name => "Bulletin ENA",
    footer    => template("c2corg/sympa/slf.fr.footer"),
  }

  sympa::list { "avalanche.en":
    send_from => "slf",
    subject   => "bulletin avalanche SAR",
    anon_name => "SAR bulletin",
    footer    => template("c2corg/sympa/slf.en.footer"),
  }

  sympa::list { "lawinen":
    send_from => "slf",
    subject   => "Lawinenbulletin SLF",
    anon_name => "Lawinenbulletin SLF",
    footer    => template("c2corg/sympa/slf.de.footer"),
  }

  sympa::list { "valanghe":
    send_from => "slf",
    subject   => "bollettino valanghe SNV",
    anon_name => "Bollettino SNV",
    footer    => template("c2corg/sympa/slf.it.footer"),
  }

  c2corg::mailinglists::meteofrance {[
    '04','05','06','09','2a','2b','31','38','64','65','66','73','74','andorre',
  ]: }

  file { "/var/cache/meteofrance":
    ensure => directory,
    owner  => "nobody",
    group  => "nogroup",
    before => Cron["bulletin nivo"],
  }

  file { "/usr/local/bin/bulletins-2005.sh":
    ensure => present,
    mode   => 755,
    source => "puppet:///c2corg/meteofrance/bulletins-2005.sh",
    before => Cron["bulletin nivo"],
  }

  cron { "bulletin nivo":
    command => "/usr/local/bin/bulletins-2005.sh",
    user    => "nobody",
    minute  => 00,
    hour    => [09,10,16,17,18,19,20],
    month   => [11,12,01,02,03,04,05], # TODO: pas sûr exactement quand ça se termine.
  }

}
