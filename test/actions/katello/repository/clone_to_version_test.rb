require 'katello_test_helper'

module Actions
  describe Katello::Repository::CloneYumMetadata do
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
      cloned_repo = ::Katello::Repository.new

      action = create_action(action_class)
      cloned_repo.expects(:link?).returns(false)
      yum_repo.expects(:build_clone).returns(cloned_repo)

      plan_action(action, [yum_repo], version)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneYumContent,
                                yum_repo, cloned_repo, [], true, :generate_metadata => true,
                                :index_content => true, :simple_clone => false)
    end

    it 'plans to clone yum metadata' do
      cloned_repo = ::Katello::Repository.new

      action = create_action(action_class)
      cloned_repo.expects(:link?).returns(true)

      yum_repo.expects(:build_clone).returns(cloned_repo)

      plan_action(action, [yum_repo], version)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneYumMetadata,
                                yum_repo, cloned_repo, :force_yum_metadata_regeneration => true)
    end

    it 'plans to clone docker units' do
      cloned_repo = docker_repo.build_clone(content_view: version.content_view,
                                            version: version)

      action = create_action(action_class)
      docker_repo.expects(:build_clone).returns(cloned_repo)

      plan_action(action, [docker_repo], version)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneDockerContent,
                                docker_repo, cloned_repo, [])
    end

    it 'plans to clone file units' do
      cloned_repo = file_repo.build_clone(content_view: version.content_view,
                                            version: version)
      action = create_action(action_class)
      file_repo.expects(:build_clone).returns(cloned_repo)

      plan_action(action, [file_repo], version)

      assert_action_planed_with(action, Actions::Katello::Repository::CloneFileContent,
                                file_repo, cloned_repo)
    end
  end
end
