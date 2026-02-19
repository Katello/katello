module Actions
  module Katello
    module Pool
      class DestroyExpired < Actions::Base
        include Actions::RecurringAction

        def run
          output[:removed_pool_ids] = ::Katello::Pool.expired.destroy_all.map(&:id)
        end

        def humanized_name
          _("Remove expired pools")
        end
      end
    end
  end
end
