module Katello
  module Concerns
    module HttpProxiesControllerExtensions
      extend ActiveSupport::Concern

      included do
        after_action :update_content_default_http_proxy, only: :create
      end

      private

      def update_content_default_http_proxy
        return unless @http_proxy.persisted?
        return unless ActiveRecord::Type::Boolean.new.deserialize(params.dig('http_proxy', 'default_content'))

        Setting[:content_default_http_proxy] = @http_proxy.name
      end
    end
  end
end
