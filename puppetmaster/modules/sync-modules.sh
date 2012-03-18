#!/bin/sh

IFS=' ' echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common 9f3107b
git://github.com/camptocamp/puppet-augeas.git augeas 762dffd
git://github.com/camptocamp/puppet-apt.git apt b3e67c69
git://github.com/camptocamp/puppet-openssl.git openssl 9c76d53
git://github.com/camptocamp/puppet-rsyncd.git rsyncd 3784b6cc
git://github.com/camptocamp/puppet-postfix.git postfix eac3705
git://github.com/camptocamp/puppet-sysctl.git sysctl bf068e0
git://github.com/camptocamp/puppet-reprepro.git reprepro 1f70375
git://github.com/kbarber/puppet-iptables.git iptables 9deddbbd
git://github.com/bodepd/puppet-sudo.git sudo 9834ac93
git://github.com/puppetlabs/puppet-vcsrepo.git vcsrepo d97e19ff9
git://github.com/puppetlabs/puppet-lvm.git lvm 75ea7be

git://github.com/camptocamp/puppet-varnish.git varnish 8cdc0130

git://github.com/camptocamp/puppet-apache.git apache 787f0946
git://github.com/camptocamp/puppet-nginx.git nginx 38767a43
git://github.com/camptocamp/puppet-postgresql.git postgresql 0a8a6856
git://github.com/camptocamp/puppet-postgis.git postgis 036937b1
git://github.com/camptocamp/puppet-mapserver.git mapserver e603dbf

git://github.com/camptocamp/puppet-collectd.git collectd cff9312

git://github.com/camptocamp/puppet-python.git python 91fe7554
git://github.com/camptocamp/puppet-ruby.git ruby d7debdf
git://github.com/camptocamp/puppet-php.git php 470a229
git://github.com/camptocamp/puppet-buildenv.git buildenv e9ff874

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
