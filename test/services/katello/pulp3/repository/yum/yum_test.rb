require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class Repository
        class YumTest < ::ActiveSupport::TestCase
          include RepositorySupport

          def setup
            @repo = katello_repositories(:fedora_17_x86_64)
            @proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          end

          def test_remote_options
            @repo.root.url = "http://foo.com/bar/"
            service = Katello::Pulp3::Repository::Yum.new(@repo, @proxy)
            assert_equal "http://foo.com/bar/", service.remote_options[:url]
            refute service.remote_options.key?(:sles_auth_token)

            @repo.root.url = "http://foo.com/bar/?mytoken"
            assert_equal "http://foo.com/bar/", service.remote_options[:url]
            assert_equal 'mytoken', service.remote_options[:sles_auth_token]
          end
        end
      end
    end
  end
end
