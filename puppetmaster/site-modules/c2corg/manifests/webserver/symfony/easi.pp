class c2corg::webserver::symfony::easi inherits c2corg::webserver::symfony {

  Vcsrepo["camptocamp.org"] {
    ensure   => undef,
    provider => "git",
    owner    => "easi",
    group    => "easi",
  }

  Vcsrepo["meta.camptocamp.org"] {
    ensure => undef,
  }

  File["c2corg conf.ini"] {
    ensure => undef,
    source => undef,
    path   => "/inexistant",
  }

  File["c2corg-envvars.sh"] {
    ensure => absent,
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
