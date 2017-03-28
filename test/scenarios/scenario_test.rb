require 'katello_test_helper'
require 'support/scenario_support'
require 'foreman_tasks/test_helpers'

module Scenarios
  class RepositoryCreateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include ForemanTasks::TestHelpers::WithInThreadExecutor

    def setup
      default_capsule = mock
      default_capsule.stubs(:default_capsule?).returns(true)
      SmartProxy.stubs(:default_capsule).returns(default_capsule)
    end

    def test_scenarios
      @support = ScenarioSupport.new(User.current)

      org = Organization.new(:name => 'scenario_test', :label => 'scenario_test')
      @support.create_org(org)
      org.reload

      product = Katello::Product.new(:name => "Scenario Product")
      @support.create_product(product, org)

      repo = Katello::Repository.new(:name => "Scenario yum product", :url => "file:///var/www/test_repos/zoo",
                                         :content_type => 'yum', :product_id => product.id,
                                          :content_view_version => org.default_content_view.versions.first,
                                          :environment => org.library, :download_policy => 'immediate', :relative_path => 'scenario_test')

      repo.pulp_id = 'scenario_test'
      @support.create_repo(repo)

      @support.sleep_if_needed
      @support.sync_repo(repo)

      @support.destroy_org(org)
    end
  end
end
