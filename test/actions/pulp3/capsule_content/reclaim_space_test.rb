require 'katello_test_helper'

module ::Actions::Pulp3::CapsuleContent
  class ReclaimSpaceTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      set_organization(Organization.find_by(label: 'Empty_Organization'))
      @primary = SmartProxy.pulp_primary
      @primary.stubs(:download_policy).returns(::Katello::RootRepository::DOWNLOAD_ON_DEMAND)
      @repo = katello_repositories(:fedora_17_x86_64)
      @repo2 = katello_repositories(:fedora_17_x86_64_duplicate)

      @repo = create_repo(@repo, @primary)
      @repo2 = create_repo(@repo2, @primary)

      @repo.root.update(download_policy: 'on_demand')
      @repo2.root.update(download_policy: 'on_demand')
    end

    def test_pulp_primary_has_space_reclaimed
      task = ForemanTasks.async_task(::Actions::Pulp3::CapsuleContent::ReclaimSpace, @primary)
      # Check that at least repo and repo2 are among the cleaned repositories
      assert_empty [@repo.version_href.split('/').slice(0, 8).join('/') + '/',
                    @repo2.version_href.split('/').slice(0, 8).join('/') + '/'] -
        task.input.with_indifferent_access[:repository_hrefs]
    end

    def test_pulp_mirror_has_space_reclaimed
      @primary.stubs(:pulp_primary?).returns(false)
      task = ForemanTasks.async_task(::Actions::Pulp3::CapsuleContent::ReclaimSpace, @primary)
      # Check that at least repo and repo2 are among the cleaned repositories
      assert_empty [@repo.version_href.split('/').slice(0, 8).join('/') + '/',
                    @repo2.version_href.split('/').slice(0, 8).join('/') + '/'] -
        task.input.with_indifferent_access[:repository_hrefs]
    end

    def test_immediate_pulp_mirror_error
      @primary.stubs(:download_policy).returns(::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
      @primary.stubs(:pulp_primary?).returns(false)

      error = assert_raises(RuntimeError) do
        ForemanTasks.async_task(::Actions::Pulp3::CapsuleContent::ReclaimSpace, @primary)
      end

      assert_equal 'Only On Demand smart proxies may have space reclaimed.', error.message
    end
  end
end
