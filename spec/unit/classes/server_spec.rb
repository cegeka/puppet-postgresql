require 'spec_helper'

describe 'postgresql::server', :type => :class do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :concat_basedir => tmpfilename('server'),
      :kernel => 'Linux',
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  describe 'with no parameters' do
    it { is_expected.to contain_class("postgresql::params") }
    it { is_expected.to contain_class("postgresql::server") }
    it 'should validate connection' do
      is_expected.to contain_postgresql__validate_db_connection('validate_service_is_running')
    end
  end

  describe 'service_ensure => running' do
    let(:params) {{ :service_ensure => 'running' }}
    it { is_expected.to contain_class("postgresql::params") }
    it { is_expected.to contain_class("postgresql::server") }
    it 'should validate connection' do
      is_expected.to contain_postgresql__validate_db_connection('validate_service_is_running')
    end
  end

  describe 'service_ensure => stopped' do
    let(:params) {{ :service_ensure => 'stopped' }}
    it { is_expected.to contain_class("postgresql::params") }
    it { is_expected.to contain_class("postgresql::server") }
    it 'shouldnt validate connection' do
      is_expected.not_to contain_postgresql__validate_db_connection('validate_service_is_running')
    end
  end

  describe 'manage_firewall => true' do
    let(:params) do
      {
        :manage_firewall => true,
        :ensure => true,
      }
    end

    it 'should create firewall rule' do
      is_expected.to contain_firewall("5432 accept - postgres")
    end
  end

  describe 'ensure => absent' do
    let(:params) do
      {
        :ensure => 'absent',
        :datadir => '/my/path',
        :xlogdir => '/xlog/path',
      }
    end

    it 'should make package purged' do
      is_expected.to contain_package('postgresql-server').with({
        :ensure => 'purged',
      })
    end

    it 'stop the service' do
      is_expected.to contain_service('postgresqld').with({
        :ensure => 'stopped',
      })
    end

    it 'should remove datadir' do
      is_expected.to contain_file('/my/path').with({
        :ensure => 'absent',
      })
    end

    it 'should remove xlogdir' do
      is_expected.to contain_file('/xlog/path').with({
        :ensure => 'absent',
      })
    end
  end

  describe 'package_ensure => absent' do
    let(:params) do
      {
        :package_ensure => 'absent',
      }
    end

    it 'should remove the package' do
      is_expected.to contain_package('postgresql-server').with({
        :ensure => 'purged',
      })
    end

    it 'should still enable the service' do
      is_expected.to contain_service('postgresqld').with({
        :ensure => 'running',
      })
    end
  end

  describe 'needs_initdb => true' do
    let(:params) do
      {
        :needs_initdb => true,
      }
    end

    it 'should contain proper initdb exec' do
      is_expected.to contain_exec('postgresql_initdb')
    end
  end
end
