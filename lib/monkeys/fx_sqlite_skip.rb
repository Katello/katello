module Fx
  module SchemaDumper
    # @api private
    module Trigger
      def tables(stream)
        unless ActiveRecord::Migration[5.2].connection.adapter_name.downcase.include?('sqlite')
          super
          triggers(stream)
        end
      end
    end
  end
end
