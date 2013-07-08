if Rails::VERSION::MAJOR < 4
  #Fix fixtures with foreign keys, fixed in Rails4
  class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    def disable_referential_integrity #:nodoc:
      if supports_disable_referential_integrity? then
        execute(tables.collect { |name| "ALTER TABLE #{quote_table_name(name)} DISABLE TRIGGER USER" }.join(";"))
      end
      yield
    ensure
      if supports_disable_referential_integrity? then
        execute(tables.collect { |name| "ALTER TABLE #{quote_table_name(name)} ENABLE TRIGGER USER" }.join(";"))
      end
    end
  end
end
