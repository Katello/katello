require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class ReclaimSpaceTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @repo = create_repo(katello_repositories(:fedora_17_x86_64), SmartProxy.pulp_primary)
      @repo.root.update(download_policy: 'on_demand')
    end

    def test_repository_has_space_reclaimed
      task = ForemanTasks.async_task(::Actions::Pulp3::Repository::ReclaimSpace,
                                      @repo)

      on_demand_repo_hrefs = [@repo.version_href.split('/').slice(0, 8).join('/') + '/']
      assert_equal task.input.with_indifferent_access[:repository_hrefs] & on_demand_repo_hrefs, on_demand_repo_hrefs
    end
  end
end
