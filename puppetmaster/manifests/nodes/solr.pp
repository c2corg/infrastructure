# VM
node 'solr' inherits 'base-node' {

  realize C2cinfra::Account::User['stef74']

  include c2corg::solr
  include c2corg::database
  include c2corg::database::replication::slave

  fact::register {
    'role': value => ['solr search'];
    'duty': value => 'prod';
  }

}
