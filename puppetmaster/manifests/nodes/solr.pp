# VM
node 'solr' inherits 'base-node' {

  fact::register {
    'role': value => ['solr search'];
    'duty': value => 'prod';
  }

}
