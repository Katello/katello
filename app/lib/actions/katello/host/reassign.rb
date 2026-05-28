module Actions
  module Katello
    module Host
      class Reassign < Actions::Base
        def plan(host, content_view_id, environment_id)
          cvenv = ::Katello::ContentViewEnvironment.find_by_cv_and_lce!(content_view_id, environment_id)
          host.content_facet.content_view_environments = [cvenv]
          host.update_candlepin_associations
        end
      end
    end
  end
end
