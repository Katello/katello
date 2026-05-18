module Actions
  module Katello
    module Host
      class RecalculateErrataStatus < Actions::Base
        def run
          ::Host.unscoped.find_each do |host|
            host.content_facet&.update_errata_status if host.subscription_facet&.uuid.present?
          rescue StandardError => error
            output[:errors] ||= []
            output[:errors] << (_("Error refreshing status for %s: ") % host.name) + error.message
          end
        end
      end
    end
  end
end
