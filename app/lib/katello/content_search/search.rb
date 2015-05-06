# a span represents a collection of rows. usually these rows represent
# a container like a product or content view

module Katello
  module ContentSearch
    class Search
      include Element
      display_attributes :rows, :name, :cols
      attr_accessor :mode

      def current_organization
        SearchUtils.current_organization
      end

      def render_to_string(*args)
        av =  ActionView::Base.new(ActionController::Base.view_paths, {})
        av.render(*args)
      end

      def mode
        @mode || 'all'
      end

      def offset
        SearchUtils.offset
      end

      def page_size
        SearchUtils.page_size
      end
    end
  end
end
