module Actions
  module Middleware
    class SwitchoverCheck < Dynflow::Middleware
      def plan(*args)
        if ::Katello::Rpm.where("pulp_id ilike '/pulp/api/v3/%'").any? && !SmartProxy.pulp_primary.pulp3_repository_type_support?('yum')
          error = "It appears that the pulp 2 to 3 switchover has been performed, but the server is still running with Pulp2. \
                   This action will cause data loss and has been stopped.  You will need to continue the upgrade \
                   in order to perform this action. "
          fail _(error)
        end
        pass(*args)
      end
    end
  end
end
