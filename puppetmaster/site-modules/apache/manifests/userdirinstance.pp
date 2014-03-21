define apache::userdirinstance ($ensure=present, $vhost) {

  include apache::params

  file { "${apache::params::root}/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    source => "puppet:///modules/${module_name}/userdir.conf",
    notify => Exec["apache-graceful"],
  }
}
