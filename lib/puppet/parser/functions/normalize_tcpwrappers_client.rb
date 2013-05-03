require 'ipaddr'

module Puppet::Parser::Functions
    newfunction(:normalize_tcpwrappers_client,
                :type => :rvalue,
                :doc => "Convert argument into TCP Wrappers-friendly version"
    ) do |args|
        args.length == 1 or
        raise Puppet::Error.new("#{__method__}: expecting 1 argument")

        client = args[0]
        retval = client

        if not client.is_a? String
            raise Puppet::Error.new("#{__method__}: argument must be a String")
        end

        # Convert to IPAddr if we can.
        begin
            ip      = IPAddr.new(client)

            # Return IPv6 as we got it, process IPv4.
            if ip.ipv4?
                masklen = client.split('/')[1] || 32
                netmask = IPAddr.new("255.255.255.255").mask(masklen)

                case netmask.to_i
                when 4294967295 # /32.
                    retval = ip.to_s
                when 4278190080, 4294901760, 4294967040 # /8, /16, /24.
                    retval = ip.to_s.split('.0')[0] + '.'
                else # Some other valid IPv4 IP/netmask.
                    retval = "#{ip.to_s}/#{netmask.to_s}"
                end
            end

        rescue ArgumentError => e
            # if client is like Hostname, FQDN, suffix, filename, keyword, etc.
            case client
            when 'ALL','LOCAL','PARANOID',/^\.?[a-z\d_.]+$/,/^\/[^ \n\t,:#]+$/
                # NOOP
            else
                raise Puppet::Error.new(
                    "#{__method__}: invalid spec: #{client}, #{e}")
            end
        end

        retval
    end
end
