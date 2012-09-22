#!/bin/sh

IFS=' ' echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common bd0572dd9
git://github.com/camptocamp/puppet-augeas.git augeas 1afd076a1
git://github.com/camptocamp/puppet-apt.git apt 44439b45c
git://github.com/camptocamp/puppet-openssl.git openssl 9c76d53
git://github.com/camptocamp/puppet-rsyncd.git rsyncd 6b9902e4
git://github.com/camptocamp/puppet-postfix.git postfix db1e5b5ea
git://github.com/camptocamp/puppet-sysctl.git sysctl bf068e0
git://github.com/camptocamp/puppet-reprepro.git reprepro 9b77b8bc4

git://github.com/kbarber/puppet-iptables.git iptables 9deddbbd
git://github.com/bodepd/puppet-sudo.git sudo 9834ac93
git://github.com/puppetlabs/puppetlabs-rabbitmq.git rabbitmq 6471580ef7
git://github.com/puppetlabs/puppetlabs-vcsrepo.git vcsrepo 44291fc
git://github.com/puppetlabs/puppetlabs-lvm.git lvm 3b1f783
git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib 44e99a7c
git://github.com/ripienaar/puppet-concat.git concat aaf2eeb027
git://github.com/puppetlabs/hiera.git hiera d1b4f7f
git://github.com/puppetlabs/hiera-puppet.git hiera-puppet bccaddc11f

git://github.com/camptocamp/puppet-varnish.git varnish 92e517a3
git://github.com/camptocamp/puppet-apache.git apache 7a3080ee3
git://github.com/camptocamp/puppet-nginx.git nginx 38767a43
git://github.com/camptocamp/puppet-postgresql.git postgresql db3ced1
git://github.com/camptocamp/puppet-postgis.git postgis d82fab5
git://github.com/camptocamp/puppet-mapserver.git mapserver 2eb908fa1d

git://github.com/camptocamp/puppet-collectd.git collectd 5e5f1040

git://github.com/camptocamp/puppet-python.git python 91fe7554
git://github.com/camptocamp/puppet-ruby.git ruby d7debdf
git://github.com/camptocamp/puppet-php.git php 02a622d3
git://github.com/camptocamp/puppet-buildenv.git buildenv 6ca5168395
git://github.com/camptocamp/puppet-kmod.git kmod f071c397a

" | egrep -v '^$|^#' | while read url module commit; do

  export GIT_WORK_TREE="$(pwd)/${module}"

  if ! [ -e "$module" ]; then
    echo -e "\n\n@@@ Cloning module $module\n"
    git clone "$url" "$module"
  else
    echo -e "\n\n@@@ Updating module $module (commit $commit)\n"
    (cd "$module" && git remote update origin && git checkout "$commit")
  fi

done
