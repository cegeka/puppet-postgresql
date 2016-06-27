require 'spec_helper_acceptance'

describe 'postgresql' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management

        class { 'cegekarepos' : stage => 'setup_repo' }

        Yum::Repo <| title == 'cegeka-custom' |>
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
        Yum::Repo <| title == 'cegeka-unsigned' |>
        Yum::Repo <| title == 'epel' |>

        class { 'postgresql::server':
          postgres_password => 'S3cR37',
        }

        postgresql::server::db { 'testdatabase':
          user     => 'testdatabaseuser',
          password => postgresql_password('testdatabaseuser', 'S3cR37'),
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(5432) do
      it { should be_listening }
    end
  end
end
