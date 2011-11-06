class c2corg::common::config {

  file { "/etc/resolv.conf":
    content => "# file managed by puppet
search camptocamp.org
nameserver 8.8.8.8
nameserver 8.8.4.4
options rotate edns0
",
  }

  file { "/etc/timezone":
    content => "Europe/Zurich\n",
    notify  => Exec["configure timezone"],
  }

  exec { "configure timezone":
    command     => "dpkg-reconfigure --priority critical tzdata",
    refreshonly => true,
  }

  case $operatingsystem {
    "Debian": {
      if $is_virtual != true {
        # kernel must reboot if panic occurs
        sysctl::set_value { "kernel.panic": value => "60" }
        if $datacenter =~ /c2corg|epnet/ {
          # disable tcp_sack due to Cisco bug in epnet routers
          sysctl::set_value { "net.ipv4.tcp_sack": value => "0" }
        }
      }
    }
    "GNU/kFreeBSD": {
      # avoid sysctl type failure
      file { "/etc/sysctl.conf": ensure => present }
    }
  }

  augeas { "sysstat history":
    context => "/files/etc/default/sysstat",
    changes => ["set HISTORY 30", "set ENABLED true"],
    notify  => Service["sysstat"],
  }

  augeas { "disable ctrl-alt-delete":
    context => "/files/etc/inittab/*[action='ctrlaltdel']/",
    changes => [
      "set runlevels 12345",
      "set process '/bin/echo ctrlaltdel disabled'"
    ],
    notify  => Exec["refresh init"],
  }

  # Gandi VMs have bad filemodes on /
  # This breaks sshd.
  file { "/":
    ensure => directory, mode => 0755,
    owner => "root", group => "root",
  }

  file { "/tmp":
    ensure => directory,
    mode   => 1777,
    owner  => "root",
    group  => "root",
  }

  exec { "refresh init":
    refreshonly => true,
    command     => "kill -HUP 1",
  }

  file { "/etc/vim/vimrc.local":
    ensure  => present,
    content => '" file managed by puppet
syntax on
set visualbell
set tabstop=2
set shiftwidth=2
set title
set expandtab
set smartindent
set smarttab
set showcmd
set showmatch
set ignorecase
set incsearch
set pastetoggle=<F2>
',
  }

  file { "/etc/profile.d/": ensure => directory }

  file { "/etc/profile":
    ensure => present,
    source => "puppet:///c2corg/profile",
  }

  file { "/etc/profile.d/path.sh":
    ensure  => present,
    content => '# file managed by puppet
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/nagios/plugins"
',
  }

  file { "/etc/profile.d/less.sh":
    ensure  => present,
    content => '# file managed by puppet
if [ "$PS1" ]; then
  export LESS="-qRI"
  eval `dircolors -b`
  eval $(lesspipe)
fi
',
  }

  file { "/etc/profile.d/history.sh":
    ensure  => present,
    content => '# file managed by puppet
if [ "$PS1" ]; then
  export HISTIGNORE="fg:bg"
  export HISTTIMEFORMAT="%h/%d – %H:%M:%S "
  export HISTCONTROL="ignoredups"
  export HISTSIZE="5000"
  export HISTFILESIZE="5000"
fi
',
  }

  file { "/etc/profile.d/aliases.sh":
    ensure  => present,
    content => '# file managed by puppet
if [ "$PS1" ]; then
  alias ls="ls --color=auto --quoting-style=escape"
  alias l="ls -Falh"
  alias grep="grep --color=auto"
  alias fgrep="fgrep --color=auto"
  alias egrep="egrep --color=auto"
fi
',
  }

}
