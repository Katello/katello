module Actions
  module Katello
    module Subscription
      class Subscribe < Actions::Base
        def plan(system_id, cp_id, quantity)
          plan_self(:user_id => ::User.current.id,
                    :quantity => quantity,
                    :cp_id => cp_id,
                    :system_id => system_id)
        end

        def run
          ::User.current = User.find(input[:user_id])
          ::Katello::System.find(input[:system_id]).subscribe(input[:cp_id], input[:quantity])
        end

        def finalize
          ::User.current = User.find(input[:user_id])
          ::Katello::Pool.find_by(:cp_id => input[:cp_id]).import_data
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
