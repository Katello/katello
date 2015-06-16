module Katello
  module Dashboard
    class Layout
      AVAILABLE_WIDGETS = %w(
        subscriptions
        subscriptions_totals
        content_views
        sync
        host_collections
        errata
      )

      attr_accessor :widgets, :columns, :organization, :current_user

      def initialize(organization, current_user)
        @widgets = []
        @columns = []
        @organization = organization
        @current_user = current_user

        AVAILABLE_WIDGETS.each do |widget_name|
          widget = get_widget(widget_name, organization)
          @widgets << widget if widget.accessible?
        end
        setup_layout
      end

      def setup_layout
        setup_default_layout
      end

      def setup_default_layout
        @columns << []
        @widgets.each_with_index { |w, i| @columns[0] << w if i.even? }
        @columns << @widgets.select { |w| !@columns[0].include?(w) }
      end

      def to_hash
        @columns.map { |col| col.map(&:name) }
      end

      def get_widget(name, org)
        "Katello::Dashboard::#{name.camelcase}Widget".constantize.new(org)
      end
    end
  end
end
