#!/bin/sh

echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common origin/master
git://github.com/camptocamp/puppet-apt.git apt origin/master
git://github.com/camptocamp/puppet-openssl.git openssl origin/master
git://github.com/camptocamp/puppet-rsyncd.git rsyncd origin/master
git://github.com/camptocamp/puppet-postfix.git postfix origin/master
git://github.com/camptocamp/puppet-sysctl.git sysctl origin/master
git://github.com/bodepd/puppet-sudo.git sudo origin/master

git://github.com/camptocamp/puppet-pacemaker.git pacemaker origin/master
git://github.com/camptocamp/puppet-varnish.git varnish origin/master
git://github.com/camptocamp/puppet-haproxy.git haproxy origin/master

git://github.com/camptocamp/puppet-apache.git apache origin/master
git://github.com/camptocamp/puppet-postgresql.git postgresql origin/master
git://github.com/camptocamp/puppet-mysql.git mysql origin/master

git://github.com/camptocamp/puppet-collectd.git collectd origin/master
git://github.com/camptocamp/puppet-nagios.git nagios origin/refactorisation

git://github.com/camptocamp/puppet-python.git python origin/master
git://github.com/camptocamp/puppet-ruby.git ruby origin/master
git://github.com/camptocamp/puppet-perl.git perl origin/master
git://github.com/camptocamp/puppet-php.git php origin/master
git://github.com/camptocamp/puppet-java.git java origin/master
git://github.com/camptocamp/puppet-buildenv.git buildenv origin/master

" | egrep -v '^$|^#' | while read item; do

  url=$(echo "$item" | cut -d' ' -f1)
  module=$(echo "$item" | cut -d' ' -f2)
  commit=$(echo "$item" | cut -d' ' -f3)

  if ! [ -e "$module" ]; then
    echo -e "\n\n@@@ Cloning module $module\n"
    git clone "$url" "$module"
  fi

  echo -e "\n\n@@@ Updating module $module (commit $commit)\n"
  (cd "$module" && git remote update && git checkout "$commit")

done
