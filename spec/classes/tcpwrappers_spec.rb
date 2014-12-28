require 'spec_helper'

describe 'tcpwrappers' do

	platforms = [
    { :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
    },
    { :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat',
    },
    { :operatingsystem => 'Darwin',
      :osfamily        => 'Darwin',
    },
    { :operatingsystem => 'Solaris',
      :osfamily        => 'Solaris',
    },
  ]
  shared_context 'install disabled' do
    it { should_not contain_package('tcpd') }
    it { should_not contain_package('tcp_wrappers') }
  end

  shared_context 'hosts.deny enabled' do
    it { should contain_concat('/etc/hosts.deny') }
    it { should_not contain_file('/etc/hosts.deny').with_ensure('absent') }
    it { should contain_concat__fragment('tcpd_deny_all_all_except_').with({
      :target  => '/etc/hosts.deny',
      :content => "# BEGIN deny everything by default\nALL:ALL\n# END\n"
    }) }
  end

  shared_context 'hosts.deny disabled' do
    it { should_not contain_concat('/etc/hosts.deny') }
    it { should contain_file('/etc/hosts.deny').with_ensure('absent') }
    it { should contain_concat__fragment('tcpd_deny_all_all_except_').with({
      :target  => '/etc/hosts.allow',
      :content => "# BEGIN deny everything by default\nALL:ALL:DENY\n# END\n"
    }) }
  end

	platforms.each do |platform|
		describe "Running on #{platform[:operatingsystem]}" do
      let(:facts) do {
        :operatingsystem => platform[:operatingsystem],
        :osfamily        => platform[:osfamily],
        :concat_basedir  => '/foo/bar/baz',
      } end
			it { should contain_concat('/etc/hosts.allow') }
			it { should contain_concat__fragment('tcpd_deny_all_all_except_').with_order(
        '999') }

      case platform[:osfamily]
      when 'Debian' then
        it { should contain_package('tcpd') }
        it_behaves_like 'hosts.deny disabled'
      when 'RedHat' then
        it { should contain_package('tcp_wrappers') }
        it_behaves_like 'hosts.deny disabled'
      else
        it_behaves_like 'install disabled'
        it_behaves_like 'hosts.deny disabled'
      end

			context 'Do not deny-by-default' do
        let(:params) do { :deny_by_default  => false } end
          it { should_not contain_concat__fragment('tcpd_deny_all_all_except_') }
			end

			context 'with hosts.deny enabled' do
        let :params do { :enable_hosts_deny => true } end
        it_behaves_like 'hosts.deny enabled'
      end
		end
	end
end
