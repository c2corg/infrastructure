#!/bin/sh

echo -e "

# format:
# URL<one space>modulename<one space>commit<newline>

git://github.com/camptocamp/puppet-common.git common origin/master
git://github.com/camptocamp/puppet-apt.git apt origin/master
git://github.com/camptocamp/puppet-postfix.git postfix origin/master

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
