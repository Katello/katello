module Katello
  module Concerns
    module ContentViewFilterRuleCommon
      extend ActiveSupport::Concern

      included do
        scoped_search on: :id, :complete_value => true
        scoped_search on: :name, :complete_value => true

        validates_lengths_from_database
      end
    end
  end
end
