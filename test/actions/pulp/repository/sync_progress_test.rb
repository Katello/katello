require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class SyncProgressTest < TestBase
    let(:action_class) { ::Actions::Pulp::Repository::Sync }

    before do
      stub_remote_user(true)
      @repo = Katello::Repository.find(katello_repositories(:fedora_17_x86_64).id)
      pulp_response = { 'spawned_tasks' => [{'task_id' => 'other' }]}
      Runcible::Resources::Repository.any_instance.stubs(:sync).returns pulp_response
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    it 'runs' do
      action        = create_action action_class
      task1         = task_base.merge('tags' => ['pulp:action:sync'])
      task2         = task1.merge(task_progress_hash(6, 8))
      task3         = task1.merge(task_progress_hash(0, 8)).merge(task_finished_hash)

      plan_action action, repo_id: @repo.id
      action = run_action action do |actn|
        stub_task_poll actn, task1, task2, task3
      end

      action.external_task[0].must_equal(task1)
      assert_equal 0.01, action.run_progress

      progress_action_time action
      assert_equal task2, action.external_task.first
      assert_equal 0.25, action.run_progress
      action.wont_be :done?

      progress_action_time action
      action.external_task[0].must_equal task3
      assert_equal 1, action.run_progress
      action.must_be :done?
    end
  end
end
