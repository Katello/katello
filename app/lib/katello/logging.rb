module Katello
  module Logging
    def self.time(message, data: {}, logger: Rails.logger, level: :info)
      start = Time.now

      yield

      data[:duration] = ((Time.now - start) * 1000).truncate(2)
      data_string = data.map { |k, v| "#{k}=#{v}" }.join(' ')

      logger.send(level, "#{message} #{data_string}")
    end
  end
end
