require 'ipaddr'

module Puppet::Parser::Functions
    newfunction(:normalize_tcpwrappers_client,
                :type => :rvalue,
                :doc => "Convert argument into TCP Wrappers-friendly version"
    ) do |args|
        args.length == 1 or
        raise Puppet::Error.new("#{__method__}: expecting 1 argument")

        # iterate over the string after we split on space
        retarr = []
        args[0].split(' ').each do |client|
            v = client

            if not client.is_a? String
                raise Puppet::Error.new(
                    "#{__method__}: argument must be a String")
            end

            # Convert to IPAddr if we can.
            begin
                ip      = IPAddr.new(client)

                # Return IPv6 as we got it, process IPv4.
                if ip.ipv4?
                    masklen = client.split('/')[1] || 32
                    netmask = IPAddr.new("255.255.255.255").mask(masklen)

                    case netmask.to_i
                    when 4278190080 # /8
                        v = ip.to_s.split('.').slice(0,1).join('.')+'.'
                    when 4294901760 # /16
                        v = ip.to_s.split('.').slice(0,2).join('.')+'.'
                    when 4294967040 # /24
                        v = ip.to_s.split('.').slice(0,3).join('.')+'.'
                    when 4294967295 # /32
                        v = ip.to_s
                    else # Some other valid IPv4 IP/netmask.
                        v = "#{ip.to_s}/#{netmask.to_s}"
                    end
                end

            rescue ArgumentError => e
                # if client is like Hostname,FQDN,suffix,filename,keyword,etc.
                case client
                when 'ALL','LOCAL','PARANOID',/^\.?[a-z\d_.]+$/,/^\/[^ \n\t,:#]+$/
                    # NOOP
                else
                    raise Puppet::Error.new(
                        "#{__method__}: invalid spec: #{client}, #{e}")
                end
            end
            retarr.push(v)
        end
        # Join on space before we return
        retarr.join(' ')
    end
end
