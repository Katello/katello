require 'katello_test_helper'

module ::Actions::Katello::Repository
  class MetadataOverlapTest < ActiveSupport::TestCase
    include Dynflow::Testing

    def setup
      @previous_user = User.current
      User.current = users(:admin)
      @repo = katello_repositories(:busybox)
      @other = katello_repositories(:redis)
      @repo.update_column(:container_repository_name, 'legacy/parent')
      @repo.reload
      @repo.stubs(:check_ready_to_act!)
      ::Katello::Pulp3::DistributionReference.delete_all
      reference(@repo, 'legacy/parent', '/pulp/dist/own/')
      reference(@other, 'legacy/parent/child', '/pulp/dist/other/')
      @action = create_action(::Actions::Katello::Repository::MetadataGenerate)
      @action.stubs(:action_subject)
    end

    def teardown
      User.current = @previous_user
    end

    def reference(repository, path, href)
      ::Katello::Pulp3::DistributionReference.create!(repository: repository, path: path, href: href)
    end

    test 'known managed conflict stops before metadata is planned' do
      @action.expects(:plan_action).never
      assert_raises(::Katello::HttpErrors::Conflict) { @action.plan(@repo) }
      assert_equal 'legacy/parent', @repo.reload.container_repository_name
    end

    test 'anonymous background user receives no repository or path details' do
      User.current = User.anonymous_api_admin
      @action.expects(:plan_action).never
      error = assert_raises(::Katello::HttpErrors::Conflict) { @action.plan(@repo) }
      assert_not_includes error.message, 'legacy/parent'
      assert_not_includes error.message, @other.name
      assert_includes error.message, 'administrator'
    end

    test 'archived metadata is checked only when distributions are enabled' do
      @repo.stubs(:environment).returns(nil)
      Setting.stubs(:[]).with(:distribute_archived_cvv).returns(false)
      @action.expects(:plan_action).once
      @action.plan(@repo)
    end

    test 'archived distribution is checked when enabled' do
      @repo.stubs(:environment).returns(nil)
      Setting.stubs(:[]).with(:distribute_archived_cvv).returns(true)
      @action.expects(:plan_action).never
      assert_raises(::Katello::HttpErrors::Conflict) { @action.plan(@repo) }
    end

    test 'container push library metadata has no distribution work' do
      @repo.root.stubs(:is_container_push).returns(true)
      @repo.stubs(:library_instance?).returns(true)
      @action.expects(:plan_action).never
      ::Katello::Validators::RepositoryContainerPathValidator.expects(:validate_existing!).never
      @action.plan(@repo)
    end

    test 'container push clone still checks its distribution' do
      @repo.root.stubs(:is_container_push).returns(true)
      @repo.stubs(:library_instance?).returns(false)
      @action.expects(:plan_action).never
      assert_raises(::Katello::HttpErrors::Conflict) { @action.plan(@repo) }
    end

    test 'unknown container path is not checked' do
      @repo.stubs(:container_repository_name).returns(nil)
      @action.expects(:plan_action).once
      @action.plan(@repo)
    end

    test 'non-container metadata and unrelated legacy overlap are not blocked' do
      rpm = katello_repositories(:fedora_17_x86_64)
      rpm.stubs(:check_ready_to_act!)
      @action.expects(:plan_action).once
      @action.plan(rpm)
    end

    test 'a repaired path proceeds despite unrelated legacy overlaps' do
      @repo.update_column(:container_repository_name, 'safe/repaired')
      @repo.reload
      @action.expects(:plan_action).once
      @action.plan(@repo)
    end
  end
end
