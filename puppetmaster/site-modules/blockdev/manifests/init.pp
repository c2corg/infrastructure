define blockdev (
  $ensure='present',
  $readonly=false,
  $blocksize=false,
  $readahead=false,
  $fsreadahead=false) {

  $device = $name
  $fname  = regsubst($name, '/', '_', 'G')

  $readpolicy = $readonly ? {
    true  => 'ro',
    false => 'rw',
  }

  file { "/etc/init.d/blockdev${fname}":
    ensure  => $ensure,
    mode    => 0755,
    content => template('blockdev/blockdev.erb'),
  }

  service { "blockdev${fname}":
    ensure  => undef,
    enable  => $ensure ? {
      present => true,
      default => false,
    },
    require => File["/etc/init.d/blockdev${fname}"],
  }

  if $ensure == 'present' {
    exec { "apply ${device} blockdev settings":
      command     => "/etc/init.d/blockdev${fname}",
      refreshonly => true,
      subscribe   => File["/etc/init.d/blockdev${fname}"],
    }
  }

}
