#!/bin/sh

IFS=' ' echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common 9f3107b
git://github.com/camptocamp/puppet-augeas.git augeas 762dffd
git://github.com/camptocamp/puppet-apt.git apt 77bf8bd
git://github.com/camptocamp/puppet-openssl.git openssl 9c76d53
git://github.com/camptocamp/puppet-rsyncd.git rsyncd 286038b
git://github.com/camptocamp/puppet-postfix.git postfix eac3705
git://github.com/camptocamp/puppet-sysctl.git sysctl bf068e0
git://github.com/camptocamp/puppet-reprepro.git reprepro 1f70375
git://github.com/kbarber/puppet-iptables.git iptables 9deddbbd
git://github.com/bodepd/puppet-sudo.git sudo 9202f636
git://github.com/puppetlabs/puppet-vcsrepo.git vcsrepo 33cca512
git://github.com/puppetlabs/puppet-lvm.git lvm 75ea7be

git://github.com/camptocamp/puppet-varnish.git varnish de4e21a

git://github.com/camptocamp/puppet-apache.git apache 787f0946
git://github.com/camptocamp/puppet-nginx.git nginx 729303b
git://github.com/camptocamp/puppet-postgresql.git postgresql 0e3afef4f
git://github.com/camptocamp/puppet-postgis.git postgis be6a90d
git://github.com/camptocamp/puppet-mapserver.git mapserver e603dbf

git://github.com/camptocamp/puppet-collectd.git collectd cff9312

git://github.com/camptocamp/puppet-python.git python 04eed22
git://github.com/camptocamp/puppet-ruby.git ruby d7debdf
git://github.com/camptocamp/puppet-php.git php 470a229
git://github.com/camptocamp/puppet-buildenv.git buildenv ad97a3b

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
