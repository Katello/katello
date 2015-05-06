module Actions
  module Katello
    module Provider
      class ManifestImport < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(provider, path, force)
          # TODO: extract the REST calls from Provider#import_manifest
          # and construct proper execution plan
          action_subject provider
          plan_self path: path, force: force
        end

        input_format do
          param :provider, Hash do
            param :id
          end
          param :path
          param :force
        end

        def humanized_name
          _("Import Manifest")
        end

        def run
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.import_manifest(input[:path],
                                   force:  input[:force])
        end
      end
    end
  end
end
