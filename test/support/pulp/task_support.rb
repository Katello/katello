module Katello
  module ConsumerSupport
    @consumer = nil

    def self.consumer_id
      @consumer.id
    end
  end
end

module Katello
  module TaskSupport
    def self.wait_on_tasks(task_list, options = {})
      task_list = [task_list] unless task_list.is_a?(Array)
      ignore_exception = options.fetch(:ignore_exception, false)
      PulpTaskStatus.wait_for_tasks(task_list)

    rescue RuntimeError => e
      unless ignore_exception
        puts e
        puts e.backtrace
      end
    rescue => e
      puts e
      puts e.backtrace
    end

    module TaskRunningWithVcr
      extend ActiveSupport::Concern

      included do
        singleton_class.alias_method_chain :any_task_running, :vcr
      end

      module ClassMethods
        def any_task_running_with_vcr(async_tasks)
          VCR.live? ? any_task_running_without_vcr(async_tasks) : false
        end
      end
    end

    Katello::PulpTaskStatus.send(:include, TaskRunningWithVcr)
  end
end
