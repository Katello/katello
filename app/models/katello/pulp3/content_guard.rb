module Katello
  module Pulp3
    class ContentGuard < Katello::Model
      def self.import(smart_proxy = SmartProxy.pulp_primary!, force = false)
        return unless (count == 0 || force)
        content_guard_api = Katello::Pulp3::Api::ContentGuard.new(smart_proxy)
        content_guard = content_guard_api.list&.results&.first
        return unless content_guard
        katello_content_guard = self.new(name: content_guard.name, pulp_href: content_guard.pulp_href)
        katello_content_guard.save!
      end
    end
  end
end
