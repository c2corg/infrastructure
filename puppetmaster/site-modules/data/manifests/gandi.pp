# hiera lookup based on "datacenter" fact
class data::gandi {
  $puppetmaster_host = '128.179.66.13'
  $resolvers = ['217.70.186.193', '217.70.186.194', '2001:4b98:dc2:49::193', '8.8.8.8']
}
