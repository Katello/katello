require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class PuppetModuleTest < ActiveSupport::TestCase
      include RepositorySupport

      def setup
        set_user

        @repository = ::Katello::Repository.find(katello_repositories(:p_forge).id)
        RepositorySupport.create_and_sync_repo(@repository)
        @repository.index_content

        @names = ["cron", "httpd", "pureftpd", "samba"]
      end

      def teardown
        RepositorySupport.destroy_repo(@repository)
      end

      def test_backend_data
        uuid = @repository.puppet_modules.first.pulp_id
        assert_equal uuid, Pulp::PuppetModule.new(uuid).backend_data['_id']
      end
    end
  end
end
