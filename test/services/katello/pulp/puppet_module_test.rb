require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class PuppetModuleTest < ActiveSupport::TestCase
      def setup
        set_user

        VCR.insert_cassette('services/pulp/puppet_module')

        @repository = Repository.find(katello_repositories(:p_forge).id)
        RepositorySupport.create_and_sync_repo(@repository)
        @repository.index_content

        @names = ["cron", "httpd", "pureftpd", "samba"]
      end

      def teardown
        RepositorySupport.destroy_repo
        VCR.eject_cassette
      end

      def test_backend_data
        uuid = @repository.puppet_modules.first.uuid
        assert_equal uuid, Pulp::PuppetModule.new(uuid).backend_data['_id']
      end
    end
  end
end
