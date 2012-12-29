#!/bin/sh

IFS=' ' echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-augeas.git augeas 3cf354f6
git://github.com/camptocamp/puppet-apt.git apt b3da98203
git://github.com/camptocamp/puppet-openssl.git openssl 9c76d53
git://github.com/camptocamp/puppet-postfix.git postfix 0537c3b4
git://github.com/duritong/puppet-sysctl.git sysctl 8f035ff5
git://github.com/camptocamp/puppet-reprepro.git reprepro 9b77b8bc4

git://github.com/kbarber/puppet-iptables.git iptables 9deddbbd
git://github.com/bodepd/puppet-sudo.git sudo 9834ac93
git://github.com/puppetlabs/puppetlabs-rabbitmq.git rabbitmq 6471580ef7
git://github.com/puppetlabs/puppetlabs-vcsrepo.git vcsrepo 109d181b
git://github.com/puppetlabs/puppetlabs-lvm.git lvm 3b1f783
git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib 44e99a7c
git://github.com/dalen/puppet-puppetdbquery.git puppetdbquery 6d16850c
git://github.com/ripienaar/puppet-concat.git concat aaf2eeb027
git://github.com/mfournier/puppet-lldp.git lldp a0553032

git://github.com/camptocamp/puppet-varnish.git varnish 89e30831
git://github.com/camptocamp/puppet-apache.git apache 7a3080ee3
git://github.com/camptocamp/puppet-nginx.git nginx 38767a43
git://github.com/camptocamp/puppet-postgresql.git postgresql b1840a6c
git://github.com/camptocamp/puppet-postgis.git postgis d82fab5
git://github.com/camptocamp/puppet-mapserver.git mapserver 2eb908fa1d

git://github.com/camptocamp/puppet-collectd.git collectd 8d369096

git://github.com/stankevich/puppet-python.git python 94d9ca52b
git://github.com/camptocamp/puppet-ruby.git ruby d7debdf
git://github.com/camptocamp/puppet-php.git php da817b136
git://github.com/camptocamp/puppet-buildenv.git buildenv 6ca5168395
git://github.com/camptocamp/puppet-kmod.git kmod bea065b60

" | egrep -v '^$|^#' | while read url module commit; do

  if [ $# -gt 0 ]; then
    [ "$module" = "$1" ] || continue
  fi

  if ! [ -e "$module" ]; then
    echo -e "\n\n@@@ Cloning module $module\n"
    git clone "$url" "$module"
  fi
  echo -e "\n\n@@@ Updating module $module (commit $commit)\n"
  (cd "$module" && \
   git remote update origin && \
   git checkout "$commit" && \
   git diff --stat origin/master)

done
