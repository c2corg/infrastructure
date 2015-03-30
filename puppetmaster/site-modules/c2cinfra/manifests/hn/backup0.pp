/* OVH unknown hardware */
class c2cinfra::hn::backup0 inherits c2cinfra::hn {

  include hardware::raid::md
  include hardware::raid::zfs

  collectd::config::plugin { 'ping home':
    plugin   => 'ping',
    settings => '
Host "128.179.66.1"
Host "128.179.66.23"
',
  }

}
