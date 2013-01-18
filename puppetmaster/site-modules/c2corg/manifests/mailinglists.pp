class c2corg::mailinglists {

  include c2cinfra::mta # just import attributes

  include c2cinfra::collectd::plugin::postfix

  $dbhost = hiera('db_host')
  $dbport = hiera('db_port')
  $dbtype = 'Pg'
  $dbname = 'c2corg'
  $dbuser = hiera('ml_db_user')
  $dbpwd  = hiera('ml_db_pass')
  $hname  = 'lists.camptocamp.org'
  $listmaster = 'listmaster@camptocamp.org'

  $postfix_smtp_listen = "0.0.0.0"
  $root_mail_recipient = $c2cinfra::mta::root_mail_recipient

  include sympa
  include sympa::mta

  @@nat::fwd { 'forward smtp port':
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
    content => '
match([sender],/@slf\.ch$/)         smtp              -> do_it
true()                              smtp,smime,md5    -> reject
',
  }

  sympa::scenari { "meteofrance":
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

  sympa::scenari { "everybody":
    content => '
match([sender],/^.*$/)     smtp             -> do_it
true()                     smtp,smime,md5   -> reject
',
  }

  sympa::list { "aran":
    send_from => "aran",
    subject   => "Boletin de lauegi",
    anon_name => "Centre de Lauegi d'Aran",
    #footer    => template("c2corg/sympa/aran.footer"),
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
    ensure => absent,
  }

  file { "/usr/local/bin/meteofrance.py":
    ensure => present,
    mode   => 755,
    source => "puppet:///modules/c2corg/meteofrance/meteofrance.py",
    before => Cron["bulletin nivo"],
  }

  package { ["python-lxml", "python-argparse"]:
    ensure => present,
    before => File["/usr/local/bin/meteofrance.py"],
  }

  cron { "bulletin nivo":
    command => "python2.6 /usr/local/bin/meteofrance.py -m smtp 2>&1 | logger -t meteofrance",
    user    => "nobody",
    minute  => 15,
    hour    => [8,10,12,16,17,18,19],
    month   => [10,11,12,01,02,03,04,05,06],
  }

  Mailalias {
    recipient => 'marc.fournier+slf@camptocamp.org',
    notify    => Exec["newaliases"],
  }

  mailalias {
    ['avalanche-owner', 'avalanche',
     'lawinen-owner', 'lawinen',
     'valanghe-owner', 'valanghe',
     'avalanche.en-owner', 'avalanche.en',
    ]: ensure    => present,
  }

}
