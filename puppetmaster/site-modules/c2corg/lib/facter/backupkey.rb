pubkey = "/root/.backupkey.pub"
if File.exist?(pubkey)
  Facter.add("backupkey") do
    setcode do
      IO.readlines(pubkey, ' ')[1]
    end
  end
end
