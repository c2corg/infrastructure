class c2corg::webserver::symfony::prod inherits c2corg::webserver::symfony {

  include c2corg::password

  $sitename = "camptocamp.org"
  $smtp_server = "127.0.0.1"
  $db_host = "192.168.192.5" # TODO: factorize
  $session_host = "192.168.192.5" # TODO: factorize
  $advertising_rw_dir = "/srv/www/camptocamp.org/www-data/persistent/advertising"

  include c2corg::memcachedb

  include c2corg::collectd::plugin::svninfo
  include c2corg::collectd::plugin::postfix


  File["c2corg conf.ini"] {
    path => "/srv/www/camptocamp.org/deployment/prod.ini",
  }

  File["c2corg-envvars.sh"] {
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'PRODUCTION'            => 'true',
    'DB_USER'               => '${c2corg::password::www_db_user}',
    'DB_PASS'               => '${c2corg::password::prod_db_pass}',
    'DB_HOST'               => '${db_host}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => 'http://s.${sitename}',
    'SMTP'                  => '${smtp_server}',
    'ADVERTISING_RW_DIR'    => '${advertising_rw_dir}',
    'ADVERTISING_ADMIN'     => '${c2corg::password::advertising_admin}',
    'GANALYTICS_KEY'        => '${c2corg::password::ganalytics_key}',
    'MOBILE_GANALYTICS_KEY' => '${c2corg::password::mobile_ganalytics_key}',
    'METAENGINE_KEY'        => '${c2corg::password::metaengine_key}',
    'GMAPS_KEY'             => '${c2corg::password::prod_gmaps_key}',
    'GEOPORTAIL_KEY'        => '${c2corg::password::prod_geoportail_key}',
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${c2corg::password::www_db_user}'",
    "PGPASSWORD='${c2corg::password::prod_db_pass}'",
    "PGHOST='${db_host}'",
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
      dsn: pgsql://${c2corg::password::www_db_user}:${c2corg::password::prod_db_pass}@${db_host}:5432/metaengine
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
