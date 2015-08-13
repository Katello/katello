module Actions
  module ElasticSearch
    module Provider
      class ReindexSubscriptions < ElasticSearch::Abstract
        input_format do
          param :id
        end

        def plan(provider)
          Type! provider, ::Katello::Provider
          plan_self(id: provider.id)
        end

        def finalize
          provider = ::Katello::Provider.find_by!(:id => input[:id])
          provider.index_subscriptions
        end
      end
    end
  end
end
