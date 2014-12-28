require 'ipaddr'

module Puppet::Parser::Functions
    newfunction(:normalize_tcpwrappers_client,
                :type => :rvalue,
                :doc => "Convert argument into TCP Wrappers-friendly version"
    ) do |args|
        args.length == 1 or
        raise Puppet::Error.new("#{__method__}: expecting 1 argument.")

        args[0].is_a? String or args[0].is_a? Array or raise Puppet::Error.new(
            "#{__method__}: expecting String or Array, got #{args[0].class()}.")

        if args[0].is_a? Array then
          args[0].each { |i|
            i.is_a? String or raise Puppet::Error.new(
              "#{__method__}: expecting Array of Strings, got #{i.class()}.")
            i.include?(' ') and raise Puppet::Error.new(
              "#{__method__}: expecting Array of Strings without spaces, got '#{i}'.")
          }
          myarr = args[0]
        else
          myarr = args[0].split(' ')
          args[0].length == 0 and raise Puppet::Error.new(
            "#{__method__}: argument must contain text.")
        end

        # iterate over each string after we split on space
        retarr = [] # array to populate.
        myarr.each do |client|
            v = nil # var to modify (or not).

            # Convert to IPAddr if we can.
            begin
                ip = IPAddr.new(client)

                # process IPv4.
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
                # Do nothing if client is a Hostname, FQDN, suffix,
                # filename,keyword,etc.
                case client
                when 'ALL'
                when 'LOCAL'
                when 'PARANOID'
                when /^\.?[a-z\d_.]+$/
                when /^\/[^ \n\t,:#]+$/
                    # all NOOP
                else
                    raise Puppet::Error.new(
                        "#{__method__}: invalid spec: #{client}, #{e}")
                end
            end
            retarr.push( v || client ) # Add selected value to array.
        end
        retarr.join(' ') # Join on space, return
    end
end
