class c2corg::webserver::symfony::dev($developer) inherits c2corg::webserver::symfony {

  $sitename = "${::hostname}.dev.camptocamp.org"

  $www_db_user = hiera('www_db_user')
  $dev_db_pass = hiera('dev_db_pass')

  File["c2corg conf.ini"] {
    path => "/srv/www/camptocamp.org/deployment/${developer}.ini",
    owner => $developer,
    group => $developer,
  }

  Vcsrepo['camptocamp.org'] {
    owner    => $developer,
    group    => $developer,
  }

  Vcsrepo["meta.camptocamp.org"] {
    owner  => $developer,
    group  => $developer,
  }

  File['/srv/www'] {
    owner  => $developer,
    group  => $developer,
  }

  File["c2corg-envvars.sh"] {
    path    => "/etc/profile.d/c2corg-envvars.sh",
    owner   => "root",
    group   => "root",
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'DB_USER'               => '${www_db_user}',
    'DB_PASS'               => '${dev_db_pass}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${www_db_user}'",
    "PGPASSWORD='${dev_db_pass}'",
  ]

  File["psql-env.sh"] {
    content => template("c2corg/symfony/psql-env.sh.erb"),
  }

}
