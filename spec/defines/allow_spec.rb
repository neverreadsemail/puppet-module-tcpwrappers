require 'spec_helper'

describe 'tcpwrappers::allow', :type => 'define' do
  let :facts  do {
    :concat_basedir  => '/foo/bar/baz',
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian',
  } end

  context 'with bad title' do
    let :title  do '192.168/16' end
    it 'should raise error due no params' do
      expect { should compile }.to raise_error(Puppet::Error,/invalid spec:/)
    end
  end

  let :title  do '10.0.0.0/255.0.0.0' end

  context 'with no params' do
    it do
      should contain_concat__fragment('tcpd_allow_all_10_except_').with(
        :order   => '100',
        :target  => '/etc/hosts.allow',
        :content => "ALL:10.:ALLOW\n",
      )
    end
    context 'and hosts.deny enabled' do
      let :pre_condition do [
        'class { tcpwrappers: enable_hosts_deny => true }',
      ] end
      it do
        should contain_concat__fragment('tcpd_allow_all_10_except_').with(
          :order   => '100',
          :target  => '/etc/hosts.allow',
          :content => "ALL:10.\n",
        )
      end
    end

  end

  context 'with a lot of params' do
    let :params do {
      :except  => '192.168.0.0/26',
      :order   => '111',
      :daemon  => 'sshd',
      :client  => ['10.0.0.0/255.255.0.0','192.168.0.0/24'],
      :comment => 'sshd tweaks',
    } end
    it do
      should contain_concat__fragment('tcpd_allow_sshd_10_0_192_168_0_except_192_168_0_0_255_255_255_192').with(
        :order   => '111',
        :target  => '/etc/hosts.allow',
        :content => "# BEGIN sshd tweaks\nsshd:10.0. 192.168.0. EXCEPT 192.168.0.0/255.255.255.192:ALLOW\n# END\n",
      )
    end

    context 'and hosts.deny enabled' do
      let :pre_condition do [
        'class { tcpwrappers: enable_hosts_deny => true }',
      ] end
      it do
        should contain_concat__fragment('tcpd_allow_sshd_10_0_192_168_0_except_192_168_0_0_255_255_255_192').with(
          :order   => '111',
          :target  => '/etc/hosts.allow',
          :content => "# BEGIN sshd tweaks\nsshd:10.0. 192.168.0. EXCEPT 192.168.0.0/255.255.255.192\n# END\n",
        )
      end
    end
  end

end
