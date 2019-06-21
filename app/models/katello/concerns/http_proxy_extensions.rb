module Katello
  module Concerns
    module HttpProxyExtensions
      extend ActiveSupport::Concern

      included do
        after_save :update_default_proxy_setting
      end

      def update_default_proxy_setting
        changes = self.previous_changes
        if changes.key?(:name)
          previous_name = changes[:name].first
          setting = Setting::Content.unscoped.
            where(name: "content_default_http_proxy").
            first

          if setting && setting.value == previous_name && !previous_name.blank?
            setting.update_attribute(:value, self.name)
          end
        end
      end

      def name_and_url
        uri = URI(url)
        uri.password = nil
        uri.user = nil
        "#{name} (#{uri})"
      end
    end
  end
end
