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
          input[:host_ids].each do |host_id|
            ::Katello::EventQueue.push_event(::Katello::Events::ImportHostErrata::EVENT_TYPE, host_id)
          end
        end
      end
    end
  end
end
