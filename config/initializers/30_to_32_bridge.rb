# This file is to track hacks that bridge the gap between 3.0 and 3.2
# and should be promptly removed and cleaned-up once the full transition
# to 3.2 is made.


module ActiveRecord
  module Persistence
    private

      def attributes_from_column_definition
        self.class.columns.inject({}) do |attributes, column|
          attributes[column.name] = column.default unless column.name == self.class.primary_key
          attributes
        end
      end

  end
end
