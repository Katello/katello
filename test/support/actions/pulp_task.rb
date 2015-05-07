module Support
  module Actions
    module PulpTask
      def task_progress_hash(left, total)
        { 'task_id'  => '76fb4115-2ec4-4945-815b-0f9d216b4183',
          'progress_report' => {
            'yum_importer' => {
              'content' => {
                'size_total' => total,
                'size_left'  => left } } } }
      end

      def task_finished_hash
        { 'finish_time' => (Time.now - 5).getgm.iso8601 }
      end

      def task_base(id = '76fb4115-2ec4-4945-815b-0f9d216b4183')
        { 'task_id' => id, 'spawned_tasks' => [] }
      end

      def stub_task_poll(action, *returns)
        task_resource = mock('task_resource').tap do |mock|
          mock.expects(:poll).times(returns.size).returns(*returns)
        end
        action.stubs(:task_resource).returns(task_resource)
      end
    end
  end
end
