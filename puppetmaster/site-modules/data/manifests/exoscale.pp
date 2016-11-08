# hiera lookup based on "datacenter" fact
class data::exoscale {
  $puppetmaster_host = '128.179.66.13'
  $resolvers = ['8.8.8.8', '8.8.4.4']
}
