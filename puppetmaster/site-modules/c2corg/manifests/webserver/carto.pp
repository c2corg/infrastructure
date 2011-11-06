class c2corg::webserver::carto {

  include c2corg::webserver

  $epsg_file = "minimal"
  include c2corg::mapserver

  package { "gpsbabel": }

  #TODO: fix postgis module to include a ::client class
  #package { "postgis": ensure => present }
}
