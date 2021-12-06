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

    def test_proper_repositories_have_space_reclaimed
      task = ForemanTasks.async_task(::Actions::Pulp3::Repository::ReclaimSpace,
                                      [@repo, @repo2, @repo3])

      on_demand_repo_hrefs = [@repo.version_href.split('/').slice(0, 8).join('/') + '/',
                              @repo2.version_href.split('/').slice(0, 8).join('/') + '/']

      immediate_repo_href = @repo3.version_href.split('/').slice(0, 8).join('/') + '/'

      refute_includes task.input.with_indifferent_access[:repository_hrefs], immediate_repo_href
      assert_equal task.input.with_indifferent_access[:repository_hrefs] & on_demand_repo_hrefs, on_demand_repo_hrefs
    end

    def test_empty_repositories_error
      error = assert_raises(RuntimeError) do
        ForemanTasks.async_task(::Actions::Pulp3::Repository::ReclaimSpace, [])
      end

      assert_equal 'No repositories selected.', error.message
    end

    def test_no_on_demand_repositories_error
      error = assert_raises(RuntimeError) do
        ForemanTasks.async_task(::Actions::Pulp3::Repository::ReclaimSpace, [@repo3])
      end

      assert_equal 'Only On Demand repositories may have space reclaimed.', error.message
    end
  end
end
