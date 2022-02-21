require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class ReclaimSpaceTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      set_organization(Organization.find_by(label: 'Empty_Organization'))
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64)
      @repo2 = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo3 = katello_repositories(:feedless_fedora_17_x86_64)
      @cv_repo = katello_repositories(:fedora_17_library_library_view)

      @repo = create_repo(@repo, @primary)
      @repo2 = create_repo(@repo2, @primary)
      @repo3 = create_repo(@repo3, @primary)
      @cv_repo = create_repo(@cv_repo, @primary)

      @repo.root.update(download_policy: 'on_demand')
      @repo2.root.update(download_policy: 'on_demand')
      @repo3.root.update(download_policy: 'immediate')
    end

    def test_repository_has_space_reclaimed
      task = ForemanTasks.async_task(::Actions::Pulp3::Repository::ReclaimSpace,
                                      @repo)

      on_demand_repo_hrefs = [@repo.version_href.split('/').slice(0, 8).join('/') + '/']
      assert_equal task.input.with_indifferent_access[:repository_hrefs] & on_demand_repo_hrefs, on_demand_repo_hrefs
    end
  end
end
