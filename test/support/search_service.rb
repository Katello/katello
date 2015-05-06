# encoding: utf-8

module Support
  module SearchService
    class FakeSearchService
      def model=(_klass)
      end

      def retrieve(*_args)
        return [], 0
      end

      def facets
        {}
      end

      def total_items
        0
      end
    end
  end
end
