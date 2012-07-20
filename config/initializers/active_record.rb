ActiveRecord::Base.include_root_in_json = false

#backporting pluck to rails 3.0
module ActiveRecord
  class Base
    class << self
      delegate :pluck, :to=> :scoped
    end
  end

  class CollectionProxy
    delegate :pluck, :to => :scoped
  end

  # = Active Record Relation
  class Relation
    # Returns <tt>Array</tt> with values of the specified column name
    # The values has same data type as column.
    #
    # Examples:
    #
    # Person.pluck(:id) # SELECT people.id FROM people
    # Person.uniq.pluck(:role) # SELECT DISTINCT role FROM people
    # Person.where(:confirmed => true).limit(5).pluck(:id)
    #
    def pluck(column_name)
      if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
        column_name = "#{table_name}.#{column_name}"
      end
      scope = self.select(column_name)
      self.connection.select_values(scope.to_sql).map! do |value|
        type_cast_using_column(value, column_for(column_name))
      end
    end
  end
end

