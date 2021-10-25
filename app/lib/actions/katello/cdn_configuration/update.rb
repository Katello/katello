module Actions
  module Katello
    module CdnConfiguration
      class Update < Actions::EntryAction
        def plan(cdn_configuration, options)
          cdn_configuration.update!(options)

          if cdn_configuration.redhat?
            cdn_configuration.ssl_cert = nil
            cdn_configuration.ssl_key = nil
          else
            resource = ::Katello::Resources::CDN::CdnResource.create(cdn_configuration: cdn_configuration)
            keypair = resource.debug_certificate
            cdn_configuration.ssl_cert = OpenSSL::X509::Certificate.new(keypair)
            cdn_configuration.ssl_key = OpenSSL::PKey::RSA.new(keypair)
          end

          cdn_configuration.save!

          org = cdn_configuration.organization
          roots = ::Katello::RootRepository.redhat.in_organization(org)
          roots.each do |root|
            full_path = if cdn_configuration.redhat?
                          root.product.repo_url(root.library_instance.generate_content_path)
                        else
                          resource.repository_url(content_label: root.content.label)
                        end
            plan_action(::Actions::Katello::Repository::Update, root, url: full_path)
          end
        end

        def humanized_name
          _("Update CDN Configuration")
        end
      end
    end
  end
end
