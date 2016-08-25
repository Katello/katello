module Actions
  module Katello
    module Host
      class GenerateApplicability < Actions::Base
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(hosts, use_queue = true)
          uuids = hosts.map { |host| host.content_facet.try(:uuid) }.compact
          unless uuids.empty?
            plan_action(Pulp::Consumer::GenerateApplicability, :uuids => uuids)
            plan_self(:host_ids => hosts.map(&:id), :use_queue => use_queue)
          end
        end

        def finalize
          input[:host_ids].each do |host_id|
            if input[:use_queue]
              ::Katello::EventQueue.push_event(::Katello::Events::ImportHostErrata::EVENT_TYPE, host_id)
            else
              host = ::Host.find(host_id)
              host.content_facet.try(:import_applicability, true) if host
            end
          end
        end
      end
    end
  end
end
