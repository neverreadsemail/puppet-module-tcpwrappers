require 'spec_helper'

describe 'the normalize_tcpwrappers_client function' do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function('normalize_tcpwrappers_client')
          ).to eq('function_normalize_tcpwrappers_client')
  end

  it 'should raise a ParseError if there is less than 2 arguments' do
    expect { scope.function_normalize_tcpwrappers_client([]) }.to(
      raise_error(Puppet::ParseError,/expecting 2 argument/))
  end

  it 'should raise a ParseError if when arg type is wrong' do
    expect { scope.function_normalize_tcpwrappers_client([{},false])}.to(
      raise_error(Puppet::ParseError,/expecting String or Array, got Hash/))
  end

  it 'should convert IPv4 class A networks into simpler form' do
    result = scope.function_normalize_tcpwrappers_client(['10.0.0.0/8',false])
    expect(result).to(eq('10.'))
  end

  it 'should convert IPv4 class B networks into simpler form' do
    result = scope.function_normalize_tcpwrappers_client(['192.168.0.0/16',false])
    expect(result).to(eq('192.168.'))
  end

  it 'should convert IPv4 class C networks into simpler form' do
    result = scope.function_normalize_tcpwrappers_client(['192.168.0.0/24',false])
    expect(result).to(eq('192.168.0.'))
  end

  it 'should convert IPv4 other sized networks into complex form' do
    result = scope.function_normalize_tcpwrappers_client(['172.16.0.0/12',false])
    expect(result).to(eq('172.16.0.0/255.240.0.0'))
  end

  it 'should surround IPv6 with brackets' do
    result = scope.function_normalize_tcpwrappers_client(['::1',true])
    expect(result).to(eq('[::1]'))
  end

  it 'should surround simplify IPv6' do
    result = scope.function_normalize_tcpwrappers_client(
      ['0000:0000:0000:0000:0000:0000:0000:0001',true])
    expect(result).to(eq('[::1]'))
  end

  it 'should surround IPv6 with brackets, but not the CIDR netmask' do
    result = scope.function_normalize_tcpwrappers_client(['fc00::/7',true])
    expect(result).to(eq('[fc00::]/7'))
  end

end
