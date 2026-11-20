module Katello
  module Util
    # PostgreSQL rejects a statement with more than 65535 bind parameters, and a
    # full_result page can carry every unit in a repository.
    module IdBatches
      MAX_IDS = 1000

      def self.slices(ids)
        ids.each_slice(MAX_IDS)
      end
    end
  end
end
