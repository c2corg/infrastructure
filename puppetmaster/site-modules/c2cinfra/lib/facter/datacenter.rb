vlan = Facter.value(:vlans)
addr = if !Facter.value(:ipaddress_docker0).nil?
         Facter.value(:ipaddress_eth0)
       elsif !Facter.value(:ipaddress_br0).nil?
         Facter.value(:ipaddress_br0)
       else
         Facter.value(:ipaddress)
       end

if vlan.is_a?(String) and vlan.split(',').include?('192')
  Facter.add('datacenter') do
    setcode do
      'c2corg'
    end
  end
else
  Facter.add('datacenter') do
    setcode do
      case addr
        when /^192\.168\.192/ then 'c2corg'
        when /^128\.179\.66/  then 'epnet'
        when /^95\.142/       then 'gandi'
        when /^46\.226\.111/  then 'gandi'
        when /^91\.121/       then 'ovh'
        when /^159\.100/      then 'exoscale'
        else 'other'
      end
    end
  end
end
