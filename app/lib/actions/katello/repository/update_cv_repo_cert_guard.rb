module Actions
  module Katello
    module Repository
      class UpdateCVRepoCertGuard < Actions::Base
        include Actions::Katello::PulpSelector

        def plan(repository, smart_proxy)
          plan_optional_pulp_action([::Actions::Pulp3::Repository::UpdateCVRepositoryCertGuard], repository, smart_proxy)
        end

        def humanized_name
          _("Updating repository authentication configuration")
        end
      end
    end
  end
end
