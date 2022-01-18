require 'katello_test_helper'

module Actions
  describe Katello::Repository::CloneToVersion do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::CloneToVersion }
    let(:yum_repo) { katello_repositories(:rhel_6_x86_64) }
    let(:docker_repo) { katello_repositories(:redis) }
    let(:file_repo) { katello_repositories(:generic_file) }
    let(:version) { katello_content_view_versions(:library_dev_view_version) }
    let(:version_solve_deps) { katello_content_view_versions(:library_view_solve_deps_version) }

    def setup
      get_organization #ensure we have an org label
    end

    it 'plans to clone yum units' do
      cloned_repo = katello_repositories(:fedora_17_x86_64)

      action = create_action(action_class)
      cloned_repo.expects(:primary?).returns(true)
      cloned_repo.root = yum_repo.root
      options = {}

      plan_action(action, [yum_repo], version, cloned_repo, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [yum_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true,
                                :solve_dependencies => false, :pulp_copy_only => false)
    end

    it 'plans to clone yum units with dependency solving' do
      cloned_repo = katello_repositories(:fedora_17_x86_64)

      action = create_action(action_class)
      cloned_repo.expects(:primary?).returns(true)

      cloned_repo.root = yum_repo.root

      plan_action(action, [yum_repo], version_solve_deps, cloned_repo, {:pulp_copy_only => true})

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [yum_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true,
                                :solve_dependencies => true, :pulp_copy_only => true)
    end

    it 'plans to clone yum metadata' do
      cloned_repo = katello_repositories(:fedora_17_x86_64)

      action = create_action(action_class)
      cloned_repo.expects(:primary?).returns(true)
      options = {}

      plan_action(action, [yum_repo], version, cloned_repo, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [yum_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true,
                                :solve_dependencies => false, :pulp_copy_only => false)
    end

    it 'plans to clone docker units' do
      cloned_repo = docker_repo.build_clone(content_view: version.content_view,
                                            version: version)

      action = create_action(action_class)
      options = {}

      plan_action(action, [docker_repo], version, cloned_repo, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [docker_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true,
                                :solve_dependencies => false, :pulp_copy_only => false)
    end

    it 'plans to clone file units' do
      cloned_repo = file_repo.build_clone(content_view: version.content_view,
                                            version: version)
      action = create_action(action_class)
      options = {}

      plan_action(action, [file_repo], version, cloned_repo, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [file_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil, :copy_contents => true,
                                :metadata_generate => true, :solve_dependencies => false, :pulp_copy_only => false)
    end

    it 'fully plans out a clone with pulp3' do
      FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)

      cloned_repo = file_repo.build_clone(content_view: version.content_view,
                                            version: version)
      cloned_repo.id = 100
      options = {}
      tree = plan_action_tree(action_class, [file_repo], version, cloned_repo, options)
      assert_tree_planned_with(tree, Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                               :source_version_repo_id => file_repo.id, :target_repo_id => cloned_repo.id)
    end

    it 'fully plans out unit copying with multiple source repositories' do
      primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)

      file_repo2 = katello_repositories(:generic_file_dev)
      cloned_repo = file_repo.build_clone(content_view: version.content_view,
                                            version: version)
      cloned_repo.id = 2000
      options = {}

      tree = plan_action_tree(action_class, [file_repo, file_repo2], version, cloned_repo, options)
      refute_tree_planned(tree, Actions::Pulp3::Orchestration::Repository::CopyAllUnits)

      assert_tree_planned_with(tree, Actions::Pulp3::Repository::CopyVersion,
                               :source_repository_id => file_repo.id,
                               :target_repository_id => cloned_repo.id,
                               :smart_proxy_id => primary.id)
      assert_tree_planned_with(tree, Actions::Pulp3::Repository::CopyContent,
                               :source_repository_id => file_repo2.id,
                               :target_repository_id => cloned_repo.id,
                               :smart_proxy_id => primary.id,
                               :filter_ids => [], :solve_dependencies => false, :rpm_filenames => nil)
    end
  end
end
