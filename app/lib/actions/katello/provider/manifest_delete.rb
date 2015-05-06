module Actions
  module Katello
    module Provider
      class ManifestDelete < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(provider)
          action_subject provider
          plan_self
        end

        input_format do
          param :provider, Hash do
            param :id
          end
        end

        def humanized_name
          _("Delete Manifest")
        end

        def run
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.delete_manifest
        end
      end
    end
  end
end
