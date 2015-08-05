module Actions
  module Katello
    module System
      class GenerateApplicability < Actions::Base
        def plan(systems)
          plan_action(Pulp::Consumer::GenerateApplicability, :uuids => systems.map(&:uuid))
          plan_self(:system_ids => systems.map(&:id))
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          systems = ::Katello::System.where(:id => input[:system_ids])
          systems.each do |system|
            system.import_applicability(false)
          end
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
