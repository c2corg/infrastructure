class c2corg::webserver::symfony::preprod inherits c2corg::webserver::symfony {

  $sitename = "pre-prod.dev.camptocamp.org"
  $statsd_host = hiera('statsd_host')
  $solr_host = hiera('solr_host')
  $www_db_user = hiera('www_db_user')
  $preprod_db_pass = hiera('preprod_db_pass')
  $preprod_gmaps_key = hiera('preprod_gmaps_key')
  $preprod_geoportail_key = hiera('preprod_geoportail_key')

  include ::c2corg::memcached

  /* hackish stuff to autotomatically install and update c2corg codebase */
  Vcsrepo['camptocamp.org'] {
    ensure   => 'latest',
    revision => 'master',
    notify   => Exec['c2corg refresh'],
  }

  Vcsrepo['meta.camptocamp.org'] {
    ensure   => 'latest',
    revision => 'master',
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
    'DB_USER'               => '${www_db_user}',
    'DB_PASS'               => '${preprod_db_pass}',
    'STATSD_HOST'           => '${statsd_host}',
    'SOLR_HOST'             => '${solr_host}',
    'SERVER_NAME'           => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => '//s.${sitename}',
    'GMAPS_KEY'             => '${preprod_gmaps_key}',
    'GEOPORTAIL_KEY'        => '${preprod_geoportail_key}',
    'SOLR_ENABLE'           => '1',
    'READONLY'              => '1'
  }
%>
export C2CORG_VARS='<%= c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';') %>'
"),
  }

  $pgvars = [
    "PGUSER='${www_db_user}'",
    "PGPASSWORD='${preprod_db_pass}'",
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
