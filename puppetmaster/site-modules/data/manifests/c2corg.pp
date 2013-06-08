# hiera lookup based on "datacenter" fact
class data::c2corg {

  $pkgrepo_host = 'pkg.pse.infra.camptocamp.org'

  $resolvers = ['192.168.192.50', '8.8.8.8', '8.8.4.4']

}
