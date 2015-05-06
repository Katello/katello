module Katello
  module Glue
    class Task
      attr_reader :name, :status, :priority, :action, :action_rollback, :timestamp

      def initialize(opts)
        @name            = opts[:name]
        @status          = opts[:status]
        @priority        = opts[:priority] || 0
        @action          = opts[:action]
        @action_rollback = opts[:action_rollback]
        update_ts
      end

      def status=(s)
        if Glue::Queue::STATUS.include?(s)
          update_ts
          @status = s
        else
          fail "invalid STATE #{s}"
        end
      end

      def to_s
        "#{name}\t #{priority}\t #{status}\t #{action}"
      end

      def to_log
        "#{name}[#{status}]"
      end

      private

      def update_ts
        @timestamp = Time.now
      end

      # sort based on priority
      def <=>(other)
        self.priority <=> other.priority
      end
    end
  end
end
