require 'katello_test_helper'

module Katello
  describe PulpTaskStatus do
    include OrchestrationHelper

    describe "proxy TaskStatus for pulp task" do
      let(:pulp_task_without_error) do
        {
          :task_id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :result => "hurray"
        }.with_indifferent_access
      end

      let(:updated_pulp_task) do
        {
          :task_id => '123',
          :state => 'finished',
          :start_time => Time.now,
          :finish_time => Time.now + 60,
          :result => "yippie"
        }.with_indifferent_access
      end

      let(:pulp_task_with_error) do
        {
          :task_id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :exception => "exception",
          :traceback => "traceback"
        }.with_indifferent_access
      end
    end
  end
end
