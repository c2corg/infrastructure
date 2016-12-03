# exoscale VMs
node /^compose.*/ {

  include c2cinfra::common
  include docker
  include docker::compose

  C2cinfra::Account::User <| tag == 'docker-compose' |>

  file { "/etc/profile.d/umask.sh":
    ensure  => present,
    content => '# file managed by puppet
umask 0002
',
  }

  fact::register {
    'role': value => ['docker'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/opt/c2corg-docker': }
}
