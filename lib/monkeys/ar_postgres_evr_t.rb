if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  module PostgreSQLAdapterExtensions
    private

    def get_oid_type(oid, fmod, column_name, sql_type = "".freeze)
      if type_map.instance_variable_get(:@mapping)["evr_t"].nil?
        type_map.register_type "evr_t", ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::EvrT.new
      end
      super
    end
  end

  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQL
        module OID # :nodoc:
          class EvrT < Type::String; end # :nodoc:
        end
      end

      class PostgreSQLAdapter < AbstractAdapter
        prepend PostgreSQLAdapterExtensions
      end
    end
  end
end
