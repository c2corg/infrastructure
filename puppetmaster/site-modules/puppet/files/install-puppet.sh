#!/bin/sh -x

test -z $1 && exit 1

suite=$1
repo="http://pkg.dev.camptocamp.org/"

echo "deb ${repo}/c2corg/ ${suite} main" > /etc/apt/sources.list.d/c2corg.list

wget -O - "${repo}/pubkey.txt" | apt-key add -

cat << EOF > /etc/apt/preferences.d/c2corg
Package: *
Pin: release l=C2corg, a=${suite}
Pin-Priority: 1100
EOF

apt-get update && apt-get -y install puppet facter ruby-hiera ruby-hiera-puppet

rm -f $0

