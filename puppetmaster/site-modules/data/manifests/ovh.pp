# hiera lookup based on "datacenter" fact
class data::ovh {
  $puppetmaster_host = '128.179.66.13'
  $resolvers = ['213.186.33.99', '8.8.8.8', '8.8.4.4']
}
