class c2corg::webserver::symfony::prod inherits c2corg::webserver::symfony {

  $sitename = "camptocamp.org"
  $smtp_server = "127.0.0.1"
  $db_host = hiera('db_host')
  $db_port = hiera('db_port')
  $statsd_host = hiera('statsd_host')
  $solr_host = hiera('solr_host')
  $www_db_user = hiera('www_db_user')
  $prod_db_pass = hiera('prod_db_pass')
  $advertising_admin = hiera('advertising_admin')
  $ganalytics_key = hiera('ganalytics_key')
  $metaengine_key = hiera('metaengine_key')
  $prod_gmaps_key = hiera('prod_gmaps_key')
  $prod_geoportail_key = hiera('prod_geoportail_key')
  $prod_https_geoportail_key = hiera('prod_https_geoportail_key')
  $camo_key = hiera('camo_key')

  $advertising_rw_dir = "/srv/www/camptocamp.org/www-data/persistent/advertising"

  include ::c2corg::memcached

  include c2cinfra::collectd::plugin::postfix

  File["c2corg conf.ini"] {
    path => "/srv/www/camptocamp.org/deployment/prod.ini",
  }

  File["c2corg-envvars.sh"] {
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'PRODUCTION'            => 'true',
    'DB_USER'               => '${www_db_user}',
    'DB_PASS'               => '${prod_db_pass}',
    'DB_HOST'               => '${db_host}',
    'DB_PORT'               => '${db_port}',
    'STATSD_HOST'           => '${statsd_host}',
    'SOLR_HOST'             => '${solr_host}',
    'SERVER_NAME'           => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => '//s.${sitename}',
    'SMTP'                  => '${smtp_server}',
    'ADVERTISING_RW_DIR'    => '${advertising_rw_dir}',
    'ADVERTISING_ADMIN'     => '${advertising_admin}',
    'GANALYTICS_KEY'        => '${ganalytics_key}',
    'METAENGINE_KEY'        => '${metaengine_key}',
    'GMAPS_KEY'             => '${prod_gmaps_key}',
    'GEOPORTAIL_KEY'        => '${prod_geoportail_key}',
    'GEOPORTAIL_HTTPS_KEY'  => '${prod_https_geoportail_key}',
    'USE_CAMO'              => 'true',
    'CAMO_KEY'              => '${camo_key}',
    'HTTPS_LOGIN'           => 'false',
    'SOLR_ENABLE'           => '1'
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${www_db_user}'",
    "PGPASSWORD='${prod_db_pass}'",
    "PGHOST='${db_host}'",
    "PGPORT='${db_port}'",
  ]

  File["psql-env.sh"] {
    content => template("c2corg/symfony/psql-env.sh.erb"),
  }


  file { "metaengine databases.yml":
    path    => "/srv/www/meta.camptocamp.org/config/databases.yml",
    content => "# file managed by puppet
# DO NOT EDIT. DO NOT COMMIT.
all:
  myConnection:
    class: sfDoctrineDatabase
    param:
      dsn: pgsql://${www_db_user}:${prod_db_pass}@${db_host}:${db_port}/metaengine
",
    require => Vcsrepo["/srv/www/meta.camptocamp.org"],
  }

  exec { "purge metaengine generated config":
    command     => "find /srv/www/meta.camptocamp.org/cache/frontend/prod/config/ -type f -delete",
    refreshonly => true,
    subscribe   => File["metaengine databases.yml"],
  }

  sudoers { 'reformat-volatile.sh script':
    users => 'c2corg',
    type  => "user_spec",
    commands => [
      '(root) /srv/www/camptocamp.org/scripts/reformat-volatile.sh',
    ],
  }

}
