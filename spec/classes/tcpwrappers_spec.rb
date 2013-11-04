
require 'spec_helper'

describe 'tcpwrappers' do

	oses = {
    'Debian' => {
      :operatingsystem        => 'Debian',
      :osfamily               => 'Debian',
      :operatingsystemrelease => '7.0',
      :lsbdistid              => 'Debian',
      :lsbdistrelease         => '7.0',
      :architecture           => 'i386',
      :kernel                 => 'Linux',
    },
    'CentOS' => {
      :operatingsystem        => 'CentOS',
      :osfamily               => '', # simulate Facter <1.6.1
      :operatingsystemrelease => '5.0',
      :lsbdistid              => 'CentOS',
      :lsbdistrelease         => '5.0',
      :architecture           => 'x86_64',
      :kernel                 => 'Linux',
    },
    'RedHat' => {
      :operatingsystem        => 'RedHat',
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.0',
      :lsbdistid              => 'RedHat',
      :lsbdistrelease         => '6.0',
      :architecture           => 'x86_64',
      :kernel                 => 'Linux',
    }
  }

	oses.keys.each do |os|
		describe "Running on #{os}" do
      let(:facts) {{
        :operatingsystem        => oses[os][:operatingsystem],
        :osfamily               => oses[os][:osfamily],
        :operatingsystemrelease => oses[os][:operatingsystemrelease],
        :architecture           => oses[os][:architecture],
        :kernel                 => oses[os][:kernel],
        :concat_basedir         => '/foo/bar/baz',
      }}
			let(:params) { { 
				:deny_by_default  => true,
			} }
			it { should contain_concat('/etc/hosts.allow') }
			it { should contain_concat('/etc/hosts.deny') }
			it { should contain_tcpwrappers__comment('hosts.allow managed by Puppet tcpwrappers').with_type('allow') }
			it { should contain_tcpwrappers__comment('hosts.deny managed by Puppet tcpwrappers').with_type('deny') }
			it { should contain_tcpwrappers__deny('tcpwrappers/deny-by-default').with_daemon('ALL').with_client('ALL') }

			context 'Do not deny-by-default' do
        let(:params) { { 
          :deny_by_default  => false,
        } }
        it { should_not contain_tcpwrappers__deny('tcpwrappers/deny-by-default') }
			end
		end
	end
end
