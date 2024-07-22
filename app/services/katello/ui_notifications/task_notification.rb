module Katello
  module UINotifications
    class TaskNotification < AbstractNotification
      def initialize(options)
        @subject = options[:subject]
        @task = options[:task]
        fail(Foreman::Exception, 'must provide notification subject') if @subject.nil?
        fail(Foreman::Exception, 'must provide related task') if @task.nil?
      end

      protected

      def actions
        ::UINotifications::URLResolver.new(
          @task,
          :links => [
            {
              :path_method => :foreman_tasks_task_path,
              :title => _('Task detail'),
            },
          ]
        ).actions
      end
    end
  end
end
