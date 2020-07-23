module Actions
  module Katello
    module Organization
      module SimpleContentAccess
        class Toggle < Actions::AbstractAsyncTask
          middleware.use Actions::Middleware::PropagateCandlepinErrors

          SIMPLE_CONTENT_ACCESS_DISABLED_VALUE = "entitlement".freeze
          SIMPLE_CONTENT_ACCESS_ENABLED_VALUE = "org_environment".freeze

          attr_reader :organization

          def plan(organization_id)
            @organization = ::Organization.find(organization_id)

            ::Katello::Resources::Candlepin::UpstreamConsumer.update(
              "#{consumer['apiUrl']}#{consumer['uuid']}",
              consumer['idCert']['cert'],
              consumer['idCert']['key'],
              nil,
              {contentAccessMode: content_access_mode_value}
            )

            plan_action(::Actions::Katello::Organization::ManifestRefresh, organization)
          end

          private

          def consumer
            @consumer ||= ::Katello::Resources::Candlepin::UpstreamCandlepinResource.upstream_consumer
          end
        end
      end
    end
  end
end
