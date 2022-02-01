module Katello
  module Logging
    def self.time(message, data: {}, logger: Rails.logger, level: :info)
      start = Time.now
      data[:success] = true

      begin
        yield(data)
      rescue => e
        data[:success] = false
        raise e
      ensure
        data[:duration] = ((Time.now - start) * 1000).truncate(2)
        data_string = data.map { |k, v| "#{k}=#{v}" }.join(' ')
        logger.send(level, "#{message} #{data_string}")
      end
    end

    class Timer
      def initialize(key = "default")
        @key = key
        Thread.current[:timers] ||= {}
        Thread.current[:timers][key] = self
        self.start
      end

      def start
        Rails.logger.info "Timer #{@key} already started; resetting start time" if @start_time
        Rails.logger.info "Timer #{@key} starting at #{Time.now}"
        @start_time = Time.now
        self
      end

      def stop
        fail ::StandardError, "Timer #{@key} is not started" unless @start_time
        duration = (Time.now - @start_time).truncate(2)
        @start_time = nil
        Rails.logger.info "Timer #{@key} stopping at #{Time.now}: #{duration} sec"
      end

      def log(msg = nil)
        duration = (Time.now - @start_time).truncate(2)
        Rails.logger.info ["Timer #{@key} running at #{Time.now}", msg, "#{duration} sec"].compact.join(': ')
      end

      def self.find_by_key(key)
        if Thread.current&.[](:timers)&.[](key)
          Thread.current[:timers][key]
        else
          Rails.logger.warn "Timer #{key} not found on current thread; creating a new timer"
          self.new(key)
        end
      end
    end
  end
end
