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
  end
end
