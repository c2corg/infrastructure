#!/bin/sh -xe

test -z $1 && exit 1
test -z $2 && exit 1

suite=$1
repo="pkg.pse.infra.camptocamp.org"

echo "deb http://${repo}/c2corg/ ${suite} main" > /etc/apt/sources.list.d/c2corg.list

wget -O - "http://${repo}/pubkey.txt" | apt-key add -

cat << EOF > /etc/apt/preferences.d/c2corg
Package: *
Pin: release l=C2corg, a=${suite}
Pin-Priority: 1100
EOF

apt-get update && apt-get -y install puppet facter ruby-hiera ruby-hiera-puppet augeas-tools

cat << EOF | augtool
set /files/etc/resolv.conf/search/domain[1] pse.infra.camptocamp.org
set /files/etc/puppet/puppet.conf/agent/certname "$2"
set /files/etc/puppet/puppet.conf/agent/waitforcert 120
set /files/etc/puppet/puppet.conf/main/server pm
set /files/etc/puppet/puppet.conf/main/pluginsync true
set /files/etc/puppet/puppet.conf/main/report true
set /files/etc/puppet/puppet.conf/main/report_server pm
set /files/etc/default/puppet/START yes
save
EOF

puppet agent --onetime --no-daemonize

rm -f $0

