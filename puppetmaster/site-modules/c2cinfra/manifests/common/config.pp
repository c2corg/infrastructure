class c2cinfra::common::config {

  $res = hiera('resolvers')

  file { "/etc/resolv.conf":
    content => inline_template('# file managed by puppet
search camptocamp.org infra.camptocamp.org
<% @res.each do |nameserver| -%>
nameserver <%= nameserver %>
<% end -%>
options timeout:2 edns0
'),
  }

  file { "/etc/timezone":
    content => "Europe/Zurich\n",
    notify  => Exec["configure timezone"],
  }

  exec { "configure timezone":
    command     => "dpkg-reconfigure --priority critical tzdata",
    refreshonly => true,
  }

  etcdefault { 'configure default locale':
     file  => 'locale',
     key   => 'LANG',
     value => 'C',
  }

  file { '/etc/mtab':
    ensure => symlink,
    target => '/proc/mounts',
  }

  Etcdefault {
    notify => Service["sysstat"],
    file   => 'sysstat',
  }

  etcdefault {
    'enable sysstat':  key => 'ENABLED', value => 'true';
    'sysstat history': key => 'HISTORY', value => '30';
  }

  #TODO: if $::virtual == 'physical' {
  if ($::virtual == 'physical' and $::lxc_container == 'false') {
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
    path    => "/etc/screenrc",
    line    => 'startup_message off',
    require => Package['screen'],
  }

  file_line { "screen: always login shell":
    path    => "/etc/screenrc",
    line    => 'defshell -$SHELL',
    require => Package['screen'],
  }

  file_line { "screen: default scrollback":
    path    => "/etc/screenrc",
    line    => 'defscrollback 5000',
    require => Package['screen'],
  }

  file { "/etc/profile.d/": ensure => directory }

  file { "/etc/profile":
    ensure => present,
    source => "puppet:///modules/c2cinfra/profile",
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

  file { '/etc/alternatives/editor':
    ensure => link,
    target => '/usr/bin/vim.basic',
  }

  sshkey { 'github.com':
    type => 'rsa',
    key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
  }

}
