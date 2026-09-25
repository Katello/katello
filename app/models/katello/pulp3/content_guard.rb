module Katello
  module Pulp3
    class ContentGuard < Katello::Model
      def self.import(smart_proxy = SmartProxy.pulp_primary!, force = false)
        return unless count == 0 || force
        content_guard_api = Katello::Pulp3::Api::ContentGuard.new(smart_proxy)
        content_guard = content_guard_api.list&.results&.first
        return unless content_guard

        # find-or-update, since force callers may re-import an already-recorded name.
        Katello::Util::Support.active_record_retry do
          existing = find_by(name: content_guard.name)
          if existing
            existing.update!(pulp_href: content_guard.pulp_href)
          else
            create!(name: content_guard.name, pulp_href: content_guard.pulp_href)
          end
        end
      end
    end
  end
end
