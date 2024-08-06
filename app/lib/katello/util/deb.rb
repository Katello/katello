module Katello
  module Util
    module Deb
      def self.parse_dependencies(deps)
        deps&.split(',')&.collect { |d| d.strip }
      end
    end
  end
end
