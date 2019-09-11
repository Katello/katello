require 'katello_test_helper'

module Katello
  module Services
    class SmartProxyRepositoryTest < ActiveSupport::TestCase
      include Support::CapsuleSupport

      let(:organization) { taxonomies(:empty_organization) }
      let(:environment) { katello_environments(:organization1_library) }
      let(:content_view) { katello_content_views(:library_view) }

      specify "listing available environments to add" do
        capsule_content.smart_proxy.available_lifecycle_environments(organization.id).wont_include(environment)

        capsule_content.smart_proxy.add_lifecycle_environment(environment)
        capsule_content.smart_proxy.available_lifecycle_environments.wont_include(environment)
      end

      specify "listing environments in the capsule" do
        capsule_content.smart_proxy.add_lifecycle_environment(environment)
        capsule_content.smart_proxy.lifecycle_environments.must_include(environment)
        capsule_content.smart_proxy.lifecycle_environments.where(organization_id: organization.id).wont_include(environment)
      end

      specify "listing capsule content in environment" do
        pulp_node_feature = Feature.create(:name => ::SmartProxy::PULP_NODE_FEATURE)
        pulp_default_feature = Feature.create(:name => ::SmartProxy::PULP_FEATURE)

        with_pulp_node = smart_proxies(:four).tap do |proxy|
          proxy.features << pulp_node_feature
        end
        with_pulp = smart_proxies(:three).tap do |proxy|
          proxy.features << pulp_default_feature
        end
        pulp_node_capsule_content = Katello::Pulp::SmartProxyRepository.new(with_pulp_node)
        pulp_node_capsule_content.smart_proxy.add_lifecycle_environment(environment)

        pulp_capsule_content = Katello::Pulp::SmartProxyRepository.new(with_pulp)
        pulp_capsule_content.smart_proxy.add_lifecycle_environment(environment)

        refute_includes ::SmartProxy.with_environment(environment, false), with_pulp
        refute_includes ::SmartProxy.with_environment(environment), with_pulp
        assert_includes ::SmartProxy.with_environment(environment), with_pulp_node

        assert_includes ::SmartProxy.with_environment(environment, true), with_pulp
        assert_includes ::SmartProxy.with_environment(environment, true), with_pulp_node
      end

      describe "task related queries" do
        def assert_tasks_equal(expected_tasks, actual_tasks)
          expected_tasks.sort_by! { |task| task.label }
          actual_tasks.sort_by! { |task| task.label }
          assert_equal(expected_tasks, actual_tasks)
        end

        before do
          @tasks = {}
          @tasks[:failed1] = FactoryBot.create(:dynflow_task, :failed)
          @tasks[:successful] = FactoryBot.create(:dynflow_task)
          @tasks[:failed2] = FactoryBot.create(:dynflow_task, :failed)
          @tasks[:failed3] = FactoryBot.create(:dynflow_task, :failed)
          @tasks[:running1] = FactoryBot.create(:dynflow_task, :running)
          @tasks[:running2] = FactoryBot.create(:dynflow_task, :running)

          @tasks.each_value do |task|
            ForemanTasks::Lock.link!(capsule_content.smart_proxy, task.id)
          end

          # create one more successful task that's not linked to the capsule
          FactoryBot.create(:dynflow_task)
        end

        test "sync tasks returns all existing tasks linked to the capsule" do
          assert_tasks_equal(@tasks.values, capsule_content.smart_proxy.sync_tasks.to_a)
        end

        test "active sync tasks" do
          assert_tasks_equal([@tasks[:running1], @tasks[:running2]], capsule_content.smart_proxy.active_sync_tasks.to_a)
        end

        test "last sync time" do
          assert_equal(@tasks[:successful].ended_at, capsule_content.smart_proxy.last_sync_time)
        end

        test "last sync time is nil when there's no successful sync" do
          @tasks[:successful].destroy
          assert_nil capsule_content.smart_proxy.last_sync_time
        end

        test "last failed sync tasks" do
          assert_tasks_equal([@tasks[:failed2], @tasks[:failed3]], capsule_content.smart_proxy.last_failed_sync_tasks.to_a)
        end
      end

      test "cancel_sync" do
        task1 = FactoryBot.create(:dynflow_task, :running)
        task2 = FactoryBot.create(:dynflow_task, :running)

        capsule_content.smart_proxy.stubs(:active_sync_tasks).returns([task1, task2])
        task1.expects(:cancel).once
        task2.expects(:cancel).once
        capsule_content.smart_proxy.cancel_sync
      end

      describe "environment_syncable?" do
        let(:environment) { katello_environments(:dev) }

        test "returns true when there's no sync task for the capsule" do
          assert capsule_content.smart_proxy.environment_syncable?(environment)
        end

        test "returns true when there's CV version published after last sync" do
          task = FactoryBot.create(:dynflow_task)
          ForemanTasks::Lock.link!(capsule_content.smart_proxy, task.id)

          environment.content_view_environments.last.update_attributes(
              :updated_at => task.ended_at.change(:month => task.ended_at.month + 1)
          )

          assert capsule_content.smart_proxy.environment_syncable?(environment)
        end

        test "returns false when a sync occured after last published CV version" do
          cv_update_date = environment.content_view_environments.last.updated_at

          task = FactoryBot.create(:dynflow_task, :started_at => cv_update_date + 1.month)
          ForemanTasks::Lock.link!(capsule_content.smart_proxy, task.id)

          refute capsule_content.smart_proxy.environment_syncable?(environment)
        end
      end

      describe "current_repositories_data" do
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
          capsule_content.smart_proxy.stubs(:pulp_repositories).returns([
                                                                          repo_lib_cv1,
                                                                          repo_lib_cv2,
                                                                          repo_dev_cv2
                                                                        ])
        end

        test "filters by environment" do
          repo_ids = capsule_content.current_repositories_data(lib).map { |repo| repo['id'] }
          expected_repo_ids = [
            repo_lib_cv1['id'],
            repo_lib_cv2['id']
          ]

          assert_equal expected_repo_ids, repo_ids
        end

        test "filters by environment and content view" do
          repo_ids = capsule_content.current_repositories_data(lib, cv1).map { |repo| repo['id'] }
          expected_repo_ids = [repo_lib_cv1['id']]

          assert_equal expected_repo_ids, repo_ids
        end

        test "returns all repositories" do
          repo_ids = capsule_content.current_repositories_data.map { |repo| repo['id'] }
          expected_repo_ids = [
            repo_lib_cv1['id'],
            repo_lib_cv2['id'],
            repo_dev_cv2['id']
          ]

          assert_equal expected_repo_ids, repo_ids
        end

        test "orphaned repos" do
          capsule_content.smart_proxy
          assert_equal [repo_lib_cv1['id'], repo_lib_cv2['id'], repo_dev_cv2['id']].sort, capsule_content.orphaned_repos.sort

          capsule_content.smart_proxy.lifecycle_environments << katello_environments(:dev)
          assert_equal [repo_lib_cv1['id'], repo_lib_cv2['id']].sort, capsule_content.orphaned_repos.sort
        end
      end
    end
  end
end
