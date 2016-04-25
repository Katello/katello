module Katello
  module DatabaseAgnosticHelper
    # Methods specific to a database
    module PostgreSQL
      def concat(*args)
        "(#{args.join(' || ')})"
      end
    end

    module MySQL
      def concat(*args)
        "CONCAT(#{args.join(', ')})"
      end
    end

    case ActiveRecord::Base.connection.adapter_name
    when "PostgreSQL"
      include PostgreSQL
    when "MySQL"
      include MySQL
    end
  end
end
