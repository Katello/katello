module Katello
  module Pulp3
    module ContentViewVersion
      class MetadataGenerator
        attr_accessor :export_service, :gpg_keys, :products

        delegate :repositories, :content_view_version, :from_content_view_version, :to => :export_service
        delegate :content_view, :to => :content_view_version
        delegate :organization, :to => :content_view

        def initialize(export_service:)
          self.export_service = export_service
          self.gpg_keys = {}
          self.products = {}
        end

        def generate!
          ret = { organization: organization.name,
                  base_path: Setting['pulpcore_export_destination'],
                  repositories: {},
                  content_view: content_view.slice(:name, :label, :description, :generated_for),
                  content_view_version: content_view_version.slice(:major, :minor, :description),
                  incremental: from_content_view_version.present?,
                  format: export_service.format,
          }
          unless from_content_view_version.blank?
            ret[:from_content_view_version] = from_content_view_version.slice(:major, :minor)
          end
          repositories.each do |repo|
            next if repo.version_href.blank?
            pulp3_repo = export_service.fetch_repository_info(repo.version_href).name
            ret[:repositories][pulp3_repo] = generate_repository_metadata(repo)
          end

          zip_products(ret[:repositories].values)

          zip_gpg_keys(ret[:repositories].values)
          zip_gpg_keys(products.values)

          ret[:products] = products
          ret[:gpg_keys] = gpg_keys
          ret
        end

        def generate_repository_metadata(repo)
          repo.slice(:name, :label, :description, :arch, :content_type, :unprotected,
                     :checksum_type, :os_versions, :major, :minor,
                     :deb_releases, :deb_components, :deb_architectures,
                     :download_policy, :mirroring_policy).
            merge(product: generate_product_metadata(repo.product),
                  gpg_key: generate_gpg_metadata(repo.gpg_key),
                  content: generate_content_metadata(repo),
                  redhat: repo.redhat?)
        end

        def generate_product_metadata(product)
          product.slice(:name, :label, :description, :cp_id).
            merge(gpg_key: generate_gpg_metadata(product.gpg_key),
                  redhat: product.redhat?)
        end

        def generate_gpg_metadata(gpg)
          return {} if gpg.blank?
          gpg.slice(:name, :content_type, :content)
        end

        def generate_content_metadata(repo)
          content = repo.content
          return {} if content.blank?
          content_data = Katello::Content.substitute_content_path(arch: repo.arch,
                                                                   releasever: repo.minor,
                                                                   content_path: content.content_url)
          { id: content.cp_content_id,
            label: content.label,
            url: content_data[:path],
          }
        end

        def zip_gpg_keys(entities)
          # this goes through each repo/product
          # identifies gpg keys
          # updates the gpg_keys map if necessary
          # replaces the value of gpg_key by just the name
          # For example:
          # Input: {label: 'repo', gpg_key: {name: 'who', content: 'great'}}
          # Output: {label: 'repo', gpg_key: {name: 'who'}}
          entities.each do |entity|
            gpg = entity[:gpg_key]
            unless gpg.blank? || gpg_keys.key?(gpg[:name])
              gpg_keys[gpg[:name]] = gpg
            end
            entity[:gpg_key] = gpg.slice(:name)
          end
        end

        def zip_products(repos)
          # this goes through each repo
          # identifies product
          # updates the products map if necessary
          # replaces the value of product by just the label
          # For example:
          # Input: {label: 'repo', product: {name: 'prod', label: 'foo', description: 'great'}}
          # Output: {label: 'repo', product: {label: 'foo'}}
          repos.each do |repo|
            product = repo[:product]
            unless products.key?(product[:label])
              products[product[:label]] = product
            end
            repo[:product] = product.slice(:label)
          end
        end
      end
    end
  end
end
