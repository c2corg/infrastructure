class salt {

  apt::key { 'F2AE6AB9':
    key_source => 'http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key',
  }

  apt::source { 'saltstack':
    location => 'http://debian.saltstack.com/debian/',
    release  => "${::lsbdistcodename}-saltstack-2014-01",
    repos    => 'main',
  }

  apt::pin { 'saltstack':
    packages   => 'salt-common salt-master salt-minion salt-syndic',
    originator => "saltstack.com",
    priority   => '1010',
  }

  apt::pin { 'zmq_from_bpo':
    packages => 'python-zmq libzmq3',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

}
