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

    def setup
      get_organization #ensure we have an org label
    end

    it 'plans to clone yum units' do
      cloned_repo = katello_repositories(:fedora_17_x86_64)

      action = create_action(action_class)
      cloned_repo.expects(:master?).returns(true)
      cloned_repo.root = yum_repo.root
      yum_repo.expects(:build_clone).returns(cloned_repo)
      options = {}

      plan_action(action, [yum_repo], version, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [yum_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true)
    end

    it 'plans to clone yum metadata' do
      cloned_repo = katello_repositories(:fedora_17_x86_64)

      action = create_action(action_class)
      cloned_repo.expects(:master?).returns(true)
      options = {}

      yum_repo.expects(:build_clone).returns(cloned_repo)

      plan_action(action, [yum_repo], version, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [yum_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true)
    end

    it 'plans to clone docker units' do
      cloned_repo = docker_repo.build_clone(content_view: version.content_view,
                                            version: version)

      action = create_action(action_class)
      docker_repo.expects(:build_clone).returns(cloned_repo)
      options = {}

      plan_action(action, [docker_repo], version, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [docker_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil,
                                :copy_contents => true, :metadata_generate => true)
    end

    it 'plans to clone file units' do
      cloned_repo = file_repo.build_clone(content_view: version.content_view,
                                            version: version)
      action = create_action(action_class)
      file_repo.expects(:build_clone).returns(cloned_repo)
      options = {}

      plan_action(action, [file_repo], version, options)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneContents, [file_repo], cloned_repo,
                                :purge_empty_contents => true, :filters => [], :rpm_filenames => nil, :copy_contents => true,
                                :metadata_generate => true)
    end
  end
end
