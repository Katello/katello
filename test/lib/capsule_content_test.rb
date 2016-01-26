require 'katello_test_helper'

module Katello
  class CapsuleContentTest < ActiveSupport::TestCase
    include Support::CapsuleSupport

    let(:organization) { taxonomies(:empty_organization) }
    let(:environment) { katello_environments(:organization1_library) }

    specify "listing available environments to add" do
      capsule_content.available_lifecycle_environments(organization.id).wont_include(environment)

      capsule_content.add_lifecycle_environment(environment)
      capsule_content.available_lifecycle_environments.wont_include(environment)
    end

    specify "listing environments in the capsule" do
      capsule_content.add_lifecycle_environment(environment)
      capsule_content.lifecycle_environments.must_include(environment)
      capsule_content.lifecycle_environments(organization.id).wont_include(environment)
    end

    specify "listing capsule content in environment" do
      pulp_node_feature = Feature.create(:name => SmartProxy::PULP_NODE_FEATURE)
      pulp_default_feature = Feature.create(:name => SmartProxy::PULP_FEATURE)

      with_pulp_node = smart_proxies(:four).tap do |proxy|
        proxy.features << pulp_node_feature
      end
      with_pulp = smart_proxies(:three).tap do |proxy|
        proxy.features << pulp_default_feature
      end
      pulp_node_capsule_content = Katello::CapsuleContent.new(with_pulp_node)
      pulp_node_capsule_content.add_lifecycle_environment(environment)

      pulp_capsule_content = Katello::CapsuleContent.new(with_pulp)
      pulp_capsule_content.add_lifecycle_environment(environment)

      refute_includes CapsuleContent.with_environment(environment, false).map(&:capsule), with_pulp
      refute_includes CapsuleContent.with_environment(environment).map(&:capsule), with_pulp
      assert_includes CapsuleContent.with_environment(environment).map(&:capsule), with_pulp_node

      assert_includes CapsuleContent.with_environment(environment, true).map(&:capsule), with_pulp
      assert_includes CapsuleContent.with_environment(environment, true).map(&:capsule), with_pulp_node
    end

    describe "task related queries" do
      def assert_tasks_equal(expected_tasks, actual_tasks)
        expected_tasks.sort_by! { |task| task.label }
        actual_tasks.sort_by! { |task| task.label }
        assert_equal(expected_tasks, actual_tasks)
      end

      before do
        @tasks = {}
        @tasks[:failed1] = FactoryGirl.create(:dynflow_task, :failed)
        @tasks[:successful] = FactoryGirl.create(:dynflow_task)
        @tasks[:failed2] = FactoryGirl.create(:dynflow_task, :failed)
        @tasks[:failed3] = FactoryGirl.create(:dynflow_task, :failed)
        @tasks[:running1] = FactoryGirl.create(:dynflow_task, :running)
        @tasks[:running2] = FactoryGirl.create(:dynflow_task, :running)

        @tasks.values.each do |task|
          ForemanTasks::Lock.link!(capsule_content.capsule, task.id)
        end

        # create one more successful task that's not linked to the capsule
        FactoryGirl.create(:dynflow_task)
      end

      test "sync tasks returns all existing tasks linked to the capsule" do
        assert_tasks_equal(@tasks.values, capsule_content.sync_tasks.to_a)
      end

      test "active sync tasks" do
        assert_tasks_equal([@tasks[:running1], @tasks[:running2]], capsule_content.active_sync_tasks.to_a)
      end

      test "last sync time" do
        assert_equal(@tasks[:successful].ended_at, capsule_content.last_sync_time)
      end

      test "last sync time is nil when there's no successful sync" do
        @tasks[:successful].destroy
        assert_equal(nil, capsule_content.last_sync_time)
      end

      test "last failed sync tasks" do
        assert_tasks_equal([@tasks[:failed2], @tasks[:failed3]], capsule_content.last_failed_sync_tasks.to_a)
      end
    end

    test "cancel_sync" do
      task1 = FactoryGirl.create(:dynflow_task, :running)
      task2 = FactoryGirl.create(:dynflow_task, :running)

      capsule_content.stubs(:active_sync_tasks).returns([task1, task2])
      task1.expects(:cancel).once
      task2.expects(:cancel).once
      capsule_content.cancel_sync
    end

    describe "environment_syncable?" do
      let(:environment) { katello_environments(:dev) }

      test "returns true when there's no sync task for the capsule" do
        assert capsule_content.environment_syncable?(environment)
      end

      test "returns true when there's CV version published after last sync" do
        task = FactoryGirl.create(:dynflow_task)
        ForemanTasks::Lock.link!(capsule_content.capsule, task.id)

        environment.content_view_environments.last.update_attributes(
          :updated_at => task.ended_at.change(:month => task.ended_at.month + 1)
        )

        assert capsule_content.environment_syncable?(environment)
      end

      test "returns false when a sync occured after last published CV version" do
        cv_update_date = environment.content_view_environments.last.updated_at

        task = FactoryGirl.create(:dynflow_task, :started_at => cv_update_date.change(:month => cv_update_date.month + 1))
        ForemanTasks::Lock.link!(capsule_content.capsule, task.id)

        refute capsule_content.environment_syncable?(environment)
      end
    end

    describe "pulp_repositories_data" do
      let(:repo_lib_cv1) do
        { "id" => FIXTURES['katello_repositories']['p_forge']['pulp_id'].to_s }
      end

      let(:repo_lib_cv2) do
        { "id" => FIXTURES['katello_repositories']['lib_p_forge']['pulp_id'].to_s }
      end

      let(:repo_dev_cv2) do
        { "id" => FIXTURES['katello_repositories']['dev_p_forge']['pulp_id'].to_s }
      end

      let(:lib) do
        katello_environments(:library)
      end

      let(:cv1) do
        katello_content_views(:acme_default)
      end

      before do
        capsule_content.capsule.stubs(:pulp_repositories).returns([
          repo_lib_cv1,
          repo_lib_cv2,
          repo_dev_cv2
        ])
      end

      test "filters by environment" do
        repo_ids = capsule_content.pulp_repositories_data(lib).map { |repo| repo['id'] }
        expected_repo_ids = [
          repo_lib_cv1['id'],
          repo_lib_cv2['id']
        ]

        assert_equal expected_repo_ids, repo_ids
      end

      test "filters by environment and content view" do
        repo_ids = capsule_content.pulp_repositories_data(lib, cv1).map { |repo| repo['id'] }
        expected_repo_ids = [
          repo_lib_cv1['id']
        ]

        assert_equal expected_repo_ids, repo_ids
      end

      test "returns all repositories" do
        repo_ids = capsule_content.pulp_repositories_data.map { |repo| repo['id'] }
        expected_repo_ids = [
          repo_lib_cv1['id'],
          repo_lib_cv2['id'],
          repo_dev_cv2['id']
        ]

        assert_equal expected_repo_ids, repo_ids
      end
    end
  end
end
