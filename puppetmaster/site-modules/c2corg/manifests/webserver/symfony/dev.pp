class c2corg::webserver::symfony::dev inherits c2corg::webserver::symfony {

  include c2corg::password
  $sitename = "${hostname}.dev.camptocamp.org"

  File["c2corg conf.ini"] {
    path => "/srv/www/camptocamp.org/deployment/${developer}.ini",
    owner => $developer,
    group => $developer,
  }

  Vcsrepo["camptocamp.org"] {
    ensure => present,
    owner  => $developer,
    group  => $developer,
  }

  Vcsrepo["meta.camptocamp.org"] {
    ensure => present,
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

  File["psql-env.sh"] {
    content => "# file managed by puppet
if [ \"\$PS1\" ]; then
  export PGUSER='${c2corg::password::www_db_user}'
  export PGPASSWORD='${c2corg::password::dev_db_pass}'
fi
",
  }

}
