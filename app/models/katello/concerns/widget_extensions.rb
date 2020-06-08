module Katello
  module Concerns
    module WidgetExtensions
      extend ActiveSupport::Concern

      module ClassMethods
        SUBSCRIPTION_TEMPLATES = %w[subscription_status_widget subscription_widget].freeze

        def without_subscription_widgets
          where.not(template: ::Widget.singleton_class::SUBSCRIPTION_TEMPLATES)
        end

        def available
          if Organization.current&.simple_content_access?
            super.without_subscription_widgets
          else
            super
          end
        end
      end
    end
  end
end
