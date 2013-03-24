# Install Puppet

apt-get -y install lsb-release

suite=$(lsb_release -c | awk '{ print $2 }')
repo="pkg.pse.infra.camptocamp.org"

echo "deb http://${repo}/c2corg/ ${suite} main" > /etc/apt/sources.list.d/c2corg.list

wget -O - "http://${repo}/pubkey.txt" | apt-key add -

cat << EOF > /etc/apt/preferences.d/c2corg
Package: *
Pin: release l=C2corg, a=${suite}
Pin-Priority: 1100
EOF

apt-get update && apt-get -y install puppet facter ruby-hiera ruby-hiera-puppet augeas-tools

cat << EOF > /etc/puppet/hiera.yaml
---
:backends: - yaml
           - puppet
:hierarchy: - %{hostname}
            - %{duty}
            - %{datacenter}
            - common
:yaml:
    :datadir: /etc/puppet/hiera

:puppet:
    :datasource: data
EOF

