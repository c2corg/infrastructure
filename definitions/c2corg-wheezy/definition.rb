#Thanks to Fletcher Nichol - https://github.com/fnichol

Veewee::Definition.declare({
  :cpu_count => '1',
  :memory_size=> '256',
  :disk_size => '25600', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Debian',
  :iso_file => "debian-wheezy-DI-b4-amd64-netinst.iso",
  :iso_src => "http://cdimage.debian.org/cdimage/wheezy_di_beta4/amd64/iso-cd/debian-wheezy-DI-b4-amd64-netinst.iso",
  :iso_md5 => "9fcd2bb541f9b6b32f2a17116d606bed",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
     '<Esc>',
     'install ',
     'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
     'debian-installer=en_US ',
     'auto ',
     'locale=en_US ',
     'kbd-chooser/method=us ',
     'netcfg/get_hostname=%NAME% ',
     'netcfg/get_domain=vagrantup.com ',
     'fb=false ',
     'debconf/frontend=noninteractive ',
     'console-setup/ask_detect=false ',
     'keyboard-configuration/xkb-keymap=us ',
     '<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "halt -p",
  :postinstall_files => [
    "base.sh",
    "vagrant.sh",
    "virtualbox.sh",
    "ruby.sh",
    "puppet.sh",
    "cleanup-virtualbox.sh",
    "cleanup.sh",
    "zerodisk.sh",
  ],
  :postinstall_timeout => "10000"
})
