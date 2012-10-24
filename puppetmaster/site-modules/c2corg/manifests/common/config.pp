class c2corg::common::config {

  file { "/etc/resolv.conf":
    content => $::datacenter ? {
      /c2corg|epnet|pse/ => "# file managed by puppet
search camptocamp.org infra.camptocamp.org
nameserver 192.168.192.50
nameserver 8.8.8.8
nameserver 8.8.4.4
options timeout:2 edns0
",
      default => "# file managed by puppet
search camptocamp.org infra.camptocamp.org
nameserver 8.8.8.8
nameserver 8.8.4.4
options rotate edns0
",
    },
  }

  file { "/etc/timezone":
    content => "Europe/Zurich\n",
    notify  => Exec["configure timezone"],
  }

  exec { "configure timezone":
    command     => "dpkg-reconfigure --priority critical tzdata",
    refreshonly => true,
  }

  case $::operatingsystem {
    "Debian": {
      if $::is_virtual != true {
        # kernel must reboot if panic occurs
        sysctl::value { "kernel.panic": value => "60" }
        if $::datacenter =~ /c2corg|epnet|pse/ {
          # disable tcp_sack due to Cisco bug in epnet routers
          sysctl::value { "net.ipv4.tcp_sack": value => "0" }
        }
      }
    }
    "GNU/kFreeBSD": {
      # avoid sysctl type failure
      file { "/etc/sysctl.conf": ensure => present }
    }
  }

  Etcdefault {
    notify => Service["sysstat"],
    file   => 'sysstat',
  }

  etcdefault {
    'enable sysstat':  key => 'ENABLED', value => 'true';
    'sysstat history': key => 'HISTORY', value => '30';
  }

  augeas { "disable ctrl-alt-delete":
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    context => "/files/etc/inittab/*[action='ctrlaltdel']/",
    changes => [
      'set runlevels 12345',
      "set process '/bin/echo ctrlaltdel disabled'"
    ],
    notify  => Exec['refresh init'],
  }

  # TODO: investigate this bug, this is silly
  # Gandi VMs have bad filemodes on /
  # This breaks sshd.
  #file { "slash":
  #  path   => '/',
  #  ensure => directory, mode => 0755,
  #  owner  => "root", group => "root",
  #}

  if $::lsbdistcodename == 'wheezy' {

    # puppet & mco packages are broken when ruby points to 1.9.1
    # revert this once packages are fixed.
    file { '/etc/alternatives/ruby':
      ensure => link,
      target => '/usr/bin/ruby1.8',
    }
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

syntax on
au BufNewFile,BufRead *.scss set filetype=css
',
  }

  file { "/etc/tmux.conf":
    ensure => present,
    content => '# file managed by puppet
set-option -g prefix C-a
unbind-key C-b
bind-key a send-prefix  # C-a a sends literal C-a
bind-key C-right next-window
bind-key C-left previous-window
bind-key / command-prompt "find-window %1"

# toggle last window like screen
unbind-key C-a
bind-key C-a last-window

set -g history-limit 5000

setw -g mode-keys vi
unbind [
bind Escape copy-mode
bind p paste-buffer
bind -t vi-copy \'v\' begin-selection
bind -t vi-copy \'y\' copy-selection
set -sg escape-time 1
',
  }

  file_line { "screen: no startup message":
    path => "/etc/screenrc",
    line => 'startup_message off',
  }

  file_line { "screen: always login shell":
    path => "/etc/screenrc",
    line => 'defshell -$SHELL',
  }

  file_line { "screen: default scrollback":
    path => "/etc/screenrc",
    line => 'defscrollback 5000',
  }

  file { "/etc/profile.d/": ensure => directory }

  file { "/etc/profile":
    ensure => present,
    source => "puppet:///modules/c2corg/profile",
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
