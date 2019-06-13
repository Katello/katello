module Katello
  module Concerns
    module HttpProxyExtensions
      extend ActiveSupport::Concern

      included do
        after_save :update_default_proxy_setting
      end

      def update_default_proxy_setting
        setting = Setting.where(name: "content_default_http_proxy").first

        if setting
          setting.update_attribute(:value, self.name)
        end
      end

      def name_and_url
        "#{name} (#{url})"
      end
    end
  end
end
