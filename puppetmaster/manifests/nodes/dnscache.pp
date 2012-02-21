# VM - RFC1918 subnet DNS cache
node 'dnscache' inherits 'base-node' {
  include unbound
}
