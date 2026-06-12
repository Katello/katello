module Katello
  module Pulp3
    module DistributionConflict
      CREATE_RACE_PATTERN = /
        ["']base_path["'].*?
        (
          unique |
          Overlaps\ with\ existing\ distribution
        )
      /mx

      def self.create_race?(error_or_message)
        message = error_or_message.respond_to?(:message) ? error_or_message.message : error_or_message.to_s
        message.match?(CREATE_RACE_PATTERN)
      end
    end
  end
end
