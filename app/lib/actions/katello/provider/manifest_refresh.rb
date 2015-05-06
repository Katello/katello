module Actions
  module Katello
    module Provider
      class ManifestRefresh < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(provider, upstream)
          action_subject provider
          plan_self :upstream => upstream
        end

        input_format do
          param :provider, Hash do
            param :id
          end
          param :upstream
        end

        def humanized_name
          _("Refresh Manifest")
        end

        def run
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.refresh_manifest(input[:upstream])
        end
      end
    end
  end
end
