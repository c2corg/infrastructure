class puppet::devel {

  package { ["rake", "rubygems", "librspec-ruby", "libmocha-ruby"]: ensure => present }

}
