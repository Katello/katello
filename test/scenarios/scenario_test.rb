require 'katello_test_helper'
require 'support/scenario_support'
require 'foreman_tasks/test_helpers'

module Scenarios
  class RepositoryCreateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include ForemanTasks::TestHelpers::WithInThreadExecutor

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    def test_scenarios
      skip "Until we can figure out testing this with pulp3"

      @support = ScenarioSupport.new(User.current)

      org = Organization.new(:name => 'scenario_test', :label => 'scenario_test')
      @support.create_org(org)
      org.reload

      product = Katello::Product.new(:name => "Scenario Product")
      @support.create_product(product, org)

      root = Katello::RootRepository.new(:name => "Scenario yum product", :url => "file:///var/lib/pulp/sync_imports/test_repos/zoo",
                                             :content_type => 'yum', :product_id => product.id,
                                             :download_policy => 'immediate')
      repo = Katello::Repository.new(:content_view_version => org.default_content_view.versions.first,
                                    :environment => org.library, :relative_path => 'scenario_test', :root => root)

      repo.pulp_id = 'scenario_test'
      @support.create_repo(repo)

      @support.sleep_if_needed
      @support.sync_repo(repo)
      @support.sleep_if_needed

      @support.update_repo(repo.root, :mirror_on_sync => false)
      @support.sleep_if_needed
      @support.destroy_org(org, repo)
    end
  end
end
