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

    class PuppetModuleNonVcrTest < ActiveSupport::TestCase
      def test_update_model
        dhcp = katello_puppet_modules(:dhcp)
        json = dhcp.attributes.merge('summary' => 'an update', 'version' => '3', 'name' => 'dns', 'author' => 'katello').as_json
        service = Pulp::PuppetModule.new(dhcp.pulp_id)
        service.backend_data = json
        service.update_model(dhcp)

        dhcp = PuppetModule.find(dhcp.id)
        assert_equal dhcp.summary, json['summary']
        assert_equal dhcp.name, json['name']
        assert_equal dhcp.author, json['author']
        assert_equal '01-3', dhcp.sortable_version
      end

      def test_update_from_json_is_idempotent
        abrt = katello_puppet_modules(:abrt)
        last_updated = abrt.updated_at
        json = abrt.attributes.as_json

        service = Pulp::PuppetModule.new(abrt.pulp_id)
        service.backend_data = json
        service.update_model(abrt)

        assert_equal PuppetModule.find(abrt.id).updated_at, last_updated
      end
    end
  end
end
