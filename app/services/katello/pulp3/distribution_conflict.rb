module Katello
  module Pulp3
    module DistributionConflict
      # Matches Pulp3 errors indicating a distribution base_path conflict
      # from a concurrent create: either a uniqueness violation or an overlap.
      CREATE_RACE_PATTERN = /
        ["']base_path["'].*?
        (
          must\ be\ unique | code=['"]unique |
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
