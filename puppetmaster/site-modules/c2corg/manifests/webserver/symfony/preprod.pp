class c2corg::webserver::symfony::preprod inherits c2corg::webserver::symfony {

  include c2corg::password
  $sitename = "pre-prod.dev.camptocamp.org"
  $session_host = hiera('session_host')
  $statsd_host = hiera('statsd_host')

  include c2corg::memcachedb

  /* hackish stuff to autotomatically install and update c2corg codebase */
  Vcsrepo["camptocamp.org"] {
    ensure => "latest",
    notify => Exec["c2corg refresh"],
  }

  Vcsrepo["meta.camptocamp.org"] {
    ensure => "latest",
  }

  File["c2corg conf.ini"] {
    path   => "/srv/www/camptocamp.org/deployment/preprod.ini",
    owner  => "c2corg",
    group  => "c2corg",
    notify => [Exec["c2corg refresh"], Exec["c2corg install"]],
  }

  File["c2corg-envvars.sh"] {
    before  => [Exec["c2corg install"], Exec["c2corg refresh"]],
    content => inline_template("# file managed by puppet
<%
  c2corg_vars = {
    'DB_USER'               => '${c2corg::password::www_db_user}',
    'DB_PASS'               => '${c2corg::password::preprod_db_pass}',
    'STATSD_HOST'           => '${statsd_host}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => 'http://s.${sitename}',
    'GMAPS_KEY'             => '${c2corg::password::preprod_gmaps_key}',
    'GEOPORTAIL_KEY'        => '${c2corg::password::preprod_geoportail_key}',
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${c2corg::password::www_db_user}'",
    "PGPASSWORD='${c2corg::password::preprod_db_pass}'",
  ]

  File["psql-env.sh"] {
    content => template("c2corg/symfony/psql-env.sh.erb"),
  }

  exec { "c2corg install":
    command => ". /home/c2corg/c2corg-envvars.sh && php c2corg --install --conf preprod",
    cwd     => "/srv/www/camptocamp.org/",
    user    => "c2corg",
    group   => "c2corg",
    notify  => Service["apache"],
    provider    => 'shell',
    logoutput   => true,
    refreshonly => true,
  }

  exec { "c2corg refresh":
    command => ". /home/c2corg/c2corg-envvars.sh && php c2corg --refresh --conf preprod --build",
    cwd     => "/srv/www/camptocamp.org/",
    user    => "c2corg",
    group   => "c2corg",
    require => Exec["c2corg install"],
    notify  => Service["apache"],
    provider    => 'shell',
    logoutput   => true,
    refreshonly => true,
  }

}
