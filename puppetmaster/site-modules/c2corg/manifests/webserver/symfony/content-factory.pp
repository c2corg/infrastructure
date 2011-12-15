class c2corg::webserver::symfony::content-factory inherits c2corg::webserver::symfony {

  include c2corg::password
  $sitename = "content-factory.dev.camptocamp.org"

  File["c2corg conf.ini"] {
    path   => "/srv/www/camptocamp.org/deployment/content-factory.ini",
    owner  => "c2corg",
    group  => "c2corg",
  }

  File["c2corg-envvars.sh"] {
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'DB_USER'               => '${c2corg::password::www_db_user}',
    'DB_PASS'               => '${c2corg::password::dev_db_pass}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${c2corg::password::www_db_user}'",
    "PGPASSWORD='${c2corg::password::dev_db_pass}'",
  ]

  File["psql-env.sh"] {
    content => template("c2corg/symfony/psql-env.sh.erb"),
  }

}
