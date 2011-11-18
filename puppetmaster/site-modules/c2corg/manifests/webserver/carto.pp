class c2corg::webserver::carto {

  include c2corg::webserver
  include postgis::client

  $epsg_file = "minimal"
  include mapserver

  package { "gpsbabel": }

}
