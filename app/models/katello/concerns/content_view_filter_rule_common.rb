module Katello
  module Concerns
    module ContentViewFilterRuleCommon
      extend ActiveSupport::Concern

      included do
        scoped_search on: :id
        scoped_search on: :name

        validates_lengths_from_database
      end
    end
  end
end
