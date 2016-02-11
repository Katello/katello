module Actions
  module Katello
    module Host
      class GenerateApplicability < Actions::Base
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(hosts)
          uuids = hosts.map { |host| host.content_facet.try(:uuid) }.compact
          unless uuids.empty?
            plan_action(Pulp::Consumer::GenerateApplicability, :uuids => uuids)
            plan_self(:host_ids => hosts.map(&:id))
          end
        end

        def finalize
          ::Host.where(:id => input[:host_ids]).each do |host|
            host.content_facet.try(:import_applicability)
            host.get_status(::Katello::ErrataStatus).refresh!
          end
        end
      end
    end
  end
end
