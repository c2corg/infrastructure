if addr = Facter.value(:ipaddress)
  Facter.add("datacenter") do
    setcode do
      case addr
        when /^128\.179\.66/ : "epnet"
        when /^95\.142/ : "gandi"
        when /^192\.168\.1/ : "c2corg"
        else "other"
      end
    end
  end
end
