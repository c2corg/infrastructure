class salt {

  apt::pin { 'saltstack_from_bpo':
    packages => 'salt-common salt-master salt-minion salt-syndic python-zmq libzmq3',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

}
