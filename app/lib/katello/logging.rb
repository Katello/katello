module Katello
  module Logging
    def self.time(message, data: {}, logger: Rails.logger, level: :info)
      start = Time.now

      yield

      data[:duration] = ((Time.now - start) * 1000).truncate(2)
      data_string = data.map { |k, v| "#{k}=#{v}" }.join(' ')

      logger.send(level, "#{message} #{data_string}")
      "#{message} #{data_string}"
    end

    class Timer
      def initialize(key = "default")
        @key = key
        @start_time = Time.now
        @@timers ||= {}
        @@timers[key] = self
      end

      def start
        Rails.logger.info "Timer #{@key} starting at #{Time.now}"
        @start_time = Time.now
        self
      end

      def stop
        duration = (Time.now - @start_time).truncate(2)
        @start_time = nil
        Rails.logger.info "Timer #{@key} stopping at #{Time.now}: #{duration} sec"
        "Timer #{@key} stopping at #{Time.now}: #{duration} sec"
      end

      def self.find_by_key(key)
        @@timers[key]
      end
    end
  end
end
