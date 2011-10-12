#!/bin/sh

IFS=' ' echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common f447c9b1
git://github.com/camptocamp/puppet-augeas.git augeas 7ce24e0c
git://github.com/camptocamp/puppet-apt.git apt f5c2a018
git://github.com/camptocamp/puppet-openssl.git openssl 7ad6bb88
git://github.com/camptocamp/puppet-rsyncd.git rsyncd 6b195689
git://github.com/camptocamp/puppet-postfix.git postfix c371b493a
git://github.com/camptocamp/puppet-sysctl.git sysctl 64a38b3e
git://github.com/camptocamp/puppet-reprepro.git reprepro 49a830b7
git://github.com/kbarber/puppet-iptables.git iptables 9deddbbd
git://github.com/bodepd/puppet-sudo.git sudo 9202f636
git://github.com/puppetlabs/puppet-vcsrepo.git vcsrepo 2723cbcd
git://github.com/puppetlabs/puppet-lvm.git lvm d92be18d

git://github.com/camptocamp/puppet-pacemaker.git pacemaker 39428d04
git://github.com/camptocamp/puppet-varnish.git varnish bb6603c7

git://github.com/camptocamp/puppet-apache.git apache 3a13c43e
git://github.com/camptocamp/puppet-postgresql.git postgresql c307d756
git://github.com/camptocamp/puppet-postgis.git postgis 42ccde5a
git://github.com/camptocamp/puppet-mapserver.git mapserver 70bab2601
git://github.com/camptocamp/puppet-mysql.git mysql cc1d19ae5

git://github.com/camptocamp/puppet-collectd.git collectd cf3479be4
git://github.com/camptocamp/puppet-nagios.git nagios e5c7a84a6

git://github.com/camptocamp/puppet-python.git python f9080352
git://github.com/camptocamp/puppet-ruby.git ruby 92768a39f
#git://github.com/camptocamp/puppet-perl.git perl origin/master
git://github.com/camptocamp/puppet-php.git php 0f99a0114
git://github.com/camptocamp/puppet-java.git java f72f1541
git://github.com/camptocamp/puppet-buildenv.git buildenv 49aa5eb66

" | egrep -v '^$|^#' | while read url module commit; do

  if ! [ -e "$module" ]; then
    echo -e "\n\n@@@ Cloning module $module\n"
    git clone "$url" "$module"
  else
    echo -e "\n\n@@@ Updating module $module (commit $commit)\n"
    (cd "$module" && git remote update && git checkout "$commit")
  fi

done
