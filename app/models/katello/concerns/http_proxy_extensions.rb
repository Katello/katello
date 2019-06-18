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
          setting = Setting.
            where(name: "content_default_http_proxy").
            where(value: previous_name.to_yaml).
            first

          if setting && !previous_name.blank?
            setting.update_attribute(:value, self.name)
          end
        end
      end

      def name_and_url
        "#{name} (#{url})"
      end
    end
  end
end
