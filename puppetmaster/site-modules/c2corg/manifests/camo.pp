class c2corg::camo {

  $camo_version = '2.1.0'

  package { 'nodejs': }

  apt::pin { 'nodejs_from_bpo':
    packages => 'nodejs',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

}
