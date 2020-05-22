module Actions
  module Katello
    module Host
      class GenerateApplicability < Actions::Base
        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def plan(hosts, use_queue = true)
          if SETTINGS[:katello][:katello_applicability]
            plan_self(:host_ids => hosts.map(&:id))
          else
            uuids = hosts.map { |host| host.content_facet.try(:uuid) }.compact
            unless uuids.empty?
              plan_action(Pulp::Consumer::GenerateApplicability, :uuids => uuids)
              plan_self(:host_ids => hosts.map(&:id), :use_queue => use_queue)
            end
          end
        end

        def finalize
          if SETTINGS[:katello][:katello_applicability]
            input[:host_ids].each do |host_id|
              ::Katello::ApplicableHostQueue.push_host(host_id)
            end
            ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)
          else
            input[:host_ids].each do |host_id|
              if input[:use_queue]
                ::Katello::EventQueue.push_event(::Katello::Events::ImportHostApplicability::EVENT_TYPE, host_id)
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
end
