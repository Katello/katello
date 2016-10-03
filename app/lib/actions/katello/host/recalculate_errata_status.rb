module Actions
  module Katello
    module Host
      class RecalculateErrataStatus < Actions::Base
        middleware.use Actions::Middleware::KeepCurrentUser

        def run
          ::Host.unscoped.find_each do |host|
            begin
              host.content_facet.update_errata_status if host.content_facet.try(:uuid)
            rescue StandardError => error
              output[:errors] ||= []
              output[:errors] << (_("Error refreshing status for %s: ") % host.name) + error.message
            end
          end
        end
      end
    end
  end
end
