require 'katello_test_helper'
require 'support/scenario_support'
require 'foreman_tasks/test_helpers'

module Scenarios
  class RepositoryCreateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include ForemanTasks::TestHelpers::WithInThreadExecutor
    include VCR::TestCase

    def setup
      @org = FactoryBot.build(:organization, :name => 'scenario_test', :label => 'scenario_test')
      @support = ScenarioSupport.new(User.current)
      @support.create_org(@org)
      @org.reload
    end

    def test_manifest_import
      manifest_path = File.join(::Katello::Engine.root, 'test', 'fixtures', 'files', 'manifest_small.zip')
      @support.import_manifest(@org.label, manifest_path)
      sleep 2
      @support.import_products(@org, manifest_path)

      assert_equal 342, @org.products.length
      assert_equal 9606, @org.product_contents.length

      manifest_path = File.join(::Katello::Engine.root, 'test', 'fixtures', 'files', 'manifest_small_modified.zip')
      @support.import_manifest(@org.label, manifest_path)
      sleep 2
      @support.import_products(@org, manifest_path)
      @org.reload

      assert_equal 342, @org.products.length
      assert_equal 9597, @org.product_contents.length

      assert @org.products.where(name: 'Red Hat Container Imagez').exists?
      assert @org.product_contents.joins(:content).where("#{Katello::Content.table_name}.name = 'Red Hat Enterprise Linux 6 Server (Containerz)'").exists?
    end

    def test_update_org_service_level
      # Without any choices, should not be able to set a service level
      assert_nil @org.service_level
      e = assert_raises(RestClient::BadRequest) do
        @org.service_level = 'Premium'
      end
      refute_nil JSON.parse(e.response)['displayMessage']
      assert_nil @org.service_level

      # Should be able to set clear the default
      @org.service_level = ''
      assert_nil @org.service_level

      # ...with a nil too
      @org.service_level = nil
      assert_nil @org.service_level
    end
  end
end
