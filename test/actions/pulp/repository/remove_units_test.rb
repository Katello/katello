require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RemoveUnitsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:action_class) { ::Actions::Pulp::Repository::RemoveUnits }

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)

      ping = {}
      [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks].each do |service|
        ping[service] = {}
        ping[service][:status] = ::Katello::Ping::OK_RETURN_CODE
      end

      ::Katello::Ping.stubs(:ping).returns(:services => ping)
    end

    describe 'RemoveUnits' do
      let(:planned_action) do
        create_and_plan_action action_class, :repo_id => repo.id
      end

      let(:planned_action_with_unit_type) do
        create_and_plan_action action_class, :repo_id => repo.id, :content_unit_type => "rpm"
      end

      let(:planned_action_with_content_units_only) do
        create_and_plan_action action_class, :repo_id => repo.id, :contents => ["1", "2"]
      end

      it 'runs with repo and gets all content types' do
        ::Katello::RepositoryTypeManager.find(repo.content_type).content_types.each do |content_type|
          content_type.pulp2_service_class.expects(:remove).once.returns('spawned_tasks' => [])
        end
        run_action planned_action
      end

      it 'runs with specified content unit type' do
        ::Katello::Pulp::Rpm.expects(:remove).once.returns('spawned_tasks' => [])
        run_action planned_action_with_unit_type
      end

      it 'fails with only content units' do
        error = proc { run_action planned_action_with_content_units_only }.must_raise(RuntimeError)
        assert_match 'Cannot pass content units without content unit type', error.message
      end
    end
  end

  class RemoveUnitTest < VCRTestBase
    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      super
      @repo_count = 18 # this will break if the test repo "zoo" changes
      ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => repo.id).main_action
    end

    def test_remove_with_repo
      assert_equal @repo_count, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length,
        "Rpm count before sync was wrong."
      ForemanTasks.sync_task(::Actions::Pulp::Repository::RemoveUnits, :repo_id => repo.id).main_action
      assert_equal 0, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end

    def test_remove_with_contents
      ForemanTasks.sync_task(::Actions::Katello::Repository::Sync, repo).main_action
      contents = ::Katello::Rpm.where(:pulp_id => ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id)).pluck(:id).sort
      assert_equal @repo_count, contents.length, "Rpm count before sync was wrong."
      set_user
      ForemanTasks.sync_task(::Actions::Pulp::Repository::RemoveUnits, :repo_id => repo.id, :contents => contents, :content_unit_type => "rpm").main_action
      assert_equal 0, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end

    def test_remove_with_content_type
      assert_equal @repo_count, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length,
        "Rpm count before sync was wrong."
      ForemanTasks.sync_task(::Actions::Pulp::Repository::RemoveUnits, :repo_id => repo.id, :content_unit_type => "rpm").main_action
      assert_equal 0, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end
  end
end
