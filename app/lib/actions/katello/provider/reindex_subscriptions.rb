module Actions
  module Katello
    module Provider
      class ReindexSubscriptions < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id
        end

        def plan(provider)
          Type! provider, ::Katello::Provider
          plan_self(id: provider.id)
        end

        def finalize
          provider = ::Katello::Provider.find_by_id!(input[:id])
          provider.index_subscriptions
        end
      end
    end
  end
end
