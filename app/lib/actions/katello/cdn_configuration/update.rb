module Actions
  module Katello
    module CdnConfiguration
      class Update < Actions::EntryAction
        def plan(cdn_configuration, url:, ssl_ca_credential_id:, ssl_cert_credential_id:, ssl_key_credential_id:)
          attrs = {}
          attrs[:url] = url if url
          attrs[:ssl_ca_credential_id] = ssl_ca_credential_id if ssl_ca_credential_id
          attrs[:ssl_cert_credential_id] = ssl_cert_credential_id if ssl_cert_credential_id
          attrs[:ssl_key_credential_id] = ssl_key_credential_id if ssl_key_credential_id

          changed = attrs.any?
          # we should validate teh cert and key when saving the configuration...
          cdn_configuration.update!(attrs)
          org = cdn_configuration.organization

          # how to correctly identity repos we need to update here?

          if changed
            org.repositories.library.for_products(org.products.redhat).each do |repo|
              #next unless repo.url #why do we do this

              root = repo.root
              mapper = root.repo_mapper
              content_url = mapper.path
              path = content_url.sub(%r{^/}, '')
              repo_url = url.sub(%r{/$}, '') # strip trailing slash - do this when saving
              new_url = "#{repo_url}/#{path}"
              plan_action(::Actions::Katello::Repository::Update, root,
                          url: new_url,
                          ssl_client_cert_id: cdn_configuration.ssl_cert_credential_id,
                          ssl_client_key_id: cdn_configuration.ssl_key_credential_id,
                          ssl_ca_cert_id: cdn_configuration.ssl_ca_credential_id
                         )
            end
          end
        end

        def humanized_name
          _("Update CDN Configuration")
        end
      end
    end
  end
end
