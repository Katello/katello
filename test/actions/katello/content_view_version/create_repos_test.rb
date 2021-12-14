require 'katello_test_helper'

module Katello::Host
  class CreateReposTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @version = katello_content_view_versions(:library_view_version_2)
    end

    describe 'VersionRepositories' do
      let(:action_class) { ::Actions::Katello::ContentViewVersion::CreateRepos }
      let(:action) { create_action action_class }

      let(:library_repo) do
        katello_repositories(:rhel_7_x86_64)
      end

      it 'plans with default values' do
        new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id, :root => library_repo.root)
        repositories = [[library_repo]]
        library_repo.expects(:build_clone).with(content_view: @version.content_view, version: @version).returns(new_repo)
        plan_action(action, @version, repositories)
        assert_action_planned_with(action, ::Actions::Katello::Repository::Create, new_repo, clone: true)
        mapping = {}
        mapping[[library_repo]] = new_repo
        assert_equal mapping, action.repository_mapping
      end
    end
  end
end
