require 'katello_test_helper'

module ::Actions::Pulp3
  class CopyAllUnitsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:generic_file)
      @clone = katello_repositories(:generic_file_dev)
    end

    def test_create
      @repo.update_attributes(:version_href => "my/custom/path")
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits, @repo, @master, @clone)
      assert_equal @repo.version_href, @clone.version_href
    end
  end
end
