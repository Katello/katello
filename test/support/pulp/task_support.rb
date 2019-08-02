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
      wait_for_tasks(task_list)
    rescue RuntimeError => e
      unless ignore_exception
        puts e
        puts e.backtrace
      end
    rescue => e
      puts e
      puts e.backtrace
    end

    def self.any_task_running(async_tasks)
      async_tasks.each do |t|
        next if t.finished?
        t.refresh
        sleep 0.5 # do not overload backend engines
        if !t.finished?
          return true
        elsif t.error?
          fail t.as_json
        end
      end
      false
    end

    def self.poll_wait_time(attempts)
      if attempts >= PulpTaskStatus::WAIT_TIMES.length * PulpTaskStatus::WAIT_TIME_STEP
        PulpTaskStatus::WAIT_TIMES.last
      else
        PulpTaskStatus::WAIT_TIMES[(attempts.to_i / PulpTaskStatus::WAIT_TIME_STEP)]
      end
    end

    def self.wait_for_tasks(async_tasks)
      async_tasks = async_tasks.collect do |t|
        unless t.nil?
          PulpTaskStatus.using_pulp_task(t)
        end
      end

      timeout_count = 0
      attempts = 0
      loop do
        begin
          break unless any_task_running(async_tasks)
          timeout_count = 0
          attempts += 1
        rescue RestClient::RequestTimeout => e
          timeout_count += 1
          Rails.logger.error "Timeout in pulp occurred: #{timeout_count}"
          raise e if timeout_count >= 10 #10 timeouts in a row, lets bail
          sleep 50 #if we got a timeout, lets backoff and let it catchup
        end
        sleep poll_wait_time(attempts)
      end
      async_tasks
    end
  end
end
