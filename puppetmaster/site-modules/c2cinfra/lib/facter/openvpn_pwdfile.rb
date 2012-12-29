pwdfile = '/srv/trac/projects/c2corg/conf/htpasswd'
if File.exist?(pwdfile)
  Facter.add('openvpn_pwdfile') do
    setcode do
      File.read(pwdfile)
    end
  end
end
