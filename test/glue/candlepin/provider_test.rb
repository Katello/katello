require 'katello_test_helper'
require 'mocha/setup'
require 'support/candlepin/owner_support'

module Katello
  class GlueCandlepinProviderTestBase < ActiveSupport::TestCase
    def self.before_suite
      super
      User.current = User.find(FIXTURES['users']['admin']['id'])
      VCR.insert_cassette('glue_candlepin_provider', :match_requests_on => [:path, :params, :method, :body_json])

      @@dev      = KTEnvironment.find(FIXTURES['katello_environments']['candlepin_dev']['id'])
      @@org      = Organization.find(FIXTURES['taxonomies']['organization2']['id'])
      @@org.setup_label_from_name
      @@provider = Provider.find(FIXTURES['katello_providers']['candlepin_redhat']['id'])

      CandlepinOwnerSupport.set_owner(@@org)
    end

    def self.after_suite
      super
      Resources::Candlepin::Owner.destroy(@@org.label)
    ensure
      VCR.eject_cassette
    end
  end

  class GlueCandlepinProviderTestImport < GlueCandlepinProviderTestBase
    def self.before_suite
      super
    end

    def self.after_suite
      super
    end

    def setup
      super
    end

    def test_manifest_import
      skip "Need testable manifests"

      # Import the newest org1 manifest - should work
      manifest = 'minitest-org1-v2'
      VCR.use_cassette("support/candlepin/provider_#{manifest}", :match_requests_on => [:path, :params, :method]) do
        @@provider.queue_import_manifest(:zip_file_path => "test/fixtures/manifests/#{manifest}.zip")
      end

      # Import the older org1 manifest - should fail
      manifest = 'minitest-org1-v1'
      VCR.use_cassette("support/candlepin/provider_#{manifest}", :match_requests_on => [:path, :params, :method]) do
        assert_raises(RestClient::Conflict) do
          @@provider.queue_import_manifest(:zip_file_path => "test/fixtures/manifests/#{manifest}.zip")
        end
      end

      # Import different org2 manifest - should fail
      manifest = 'minitest-org2-v1'
      VCR.use_cassette("support/candlepin/provider_#{manifest}", :match_requests_on => [:path, :params, :method]) do
        @@provider.queue_import_manifest(:zip_file_path => "test/fixtures/manifests/#{manifest}.zip")
      end

      manifest = 'minitest-org1-v2'
      VCR.use_cassette("support/candlepin/provider_#{manifest}", :match_requests_on => [:path, :params, :method]) do
        @@provider.queue_delete_manifest
      end
    end
  end

  class GlueCandlepinProviderTestDelete < GlueCandlepinProviderTestBase
    #until we can import a fake manifest into candlepin, this the best we can do
    def test_manifest_delete
      @@provider.stubs(:index_subscriptions).returns(true)
      Resources::Candlepin::Owner.stubs(:pools).returns([])
      Resources::Candlepin::Owner.stubs(:destroy_imports).with(@@provider.organization.label, true).returns(true)
      @@provider.delete_manifest
    end
  end
end
