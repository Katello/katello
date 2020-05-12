require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    if const_defined? :PostgreSQLAdapter
      class PostgreSQLAdapter
        NATIVE_DATABASE_TYPES.merge!(
          debversion: { name: 'debversion' }
        )
      end

      module AddCustomOIDs
        def initialize_type_map(m = type_map)
          m.register_type(
            'debversion',
            ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::SpecializedString.new(:debversion)
          )
          super(m)
        end
      end

      PostgreSQLAdapter.prepend AddCustomOIDs
    end

    if const_defined? :PostgreSQL
      module PostgreSQL
        module AdditionalColumnMethods
          extend ActiveSupport::Concern
          included do
            define_column_methods :debversion
          end
        end

        TableDefinition.include AdditionalColumnMethods
        Table.include AdditionalColumnMethods
      end
    end
  end
end
