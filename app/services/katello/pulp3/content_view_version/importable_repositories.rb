module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableRepositories
        attr_reader :creatable, :updatable, :organization, :metadata, :redhat

        def initialize(organization:, metadata:, redhat: false)
          @organization = organization
          @metadata = metadata
          @creatable = []
          @updatable = []
          @redhat = redhat
        end

        def product_content_by_label(content_label)
          ::Katello::Content.find_by_label(content_label)
        end

        def repositories_in_library
          return @repositories_in_library unless @repositories_in_library.blank?
          repo_type = redhat ? :redhat : :custom
          # fetch a list of [product, repo] pairs for every non-redhat library repo
          product_repos_in_library = Import.repositories_in_library(organization).send(repo_type).
                                      pluck("#{Katello::Product.table_name}.label",
                                            "#{Katello::RootRepository.table_name}.label")
          @repositories_in_library = Set.new(product_repos_in_library.compact)
        end

        def generate!
          # This set's up a 2 different list of importable root repositories
          # creatable: repos that are part of the metadata but not in the library.
          #         They are ready to be created
          # updatable: repo that are both in the metadata and library.
          #         These may contain updates to the repo and hence ready to be updated.
          metadata_map = Import.metadata_map(metadata, custom_only: !redhat, redhat_only: redhat)
          metadata_map.keys.each do |product_label, repo_label|
            product = Katello::Product.in_org(organization).find_by(label: product_label)
            fail _("Unable to find product '%s' in organization '%s'" % [product_label, organization.name]) if product.blank?
            params = metadata_map[[product_label, repo_label]]
            if params[:gpg_key].blank?
              params[:gpg_key_id] = nil
            else
              params[:gpg_key_id] = organization.gpg_keys.find_by(name: params[:gpg_key][:name]).id
            end
            content = params[:content]
            params = params.except(:redhat, :product, :gpg_key, :content)
            if repositories_in_library.include? [product_label, repo_label]
              repo = ::Katello::RootRepository.find_by(product: product, label: repo_label)
              updatable << { repository: repo, options: params.except(:label, :name, :content_type) }
            elsif redhat
              product_content = product_content_by_label(content[:label])
              substitutions = {
                basearch: params[:arch],
                releasever: params[:minor]
              }
              creatable << { product: product, content: product_content, substitutions: substitutions }
            else
              creatable << { repository: product.add_repo(params) }
            end
          end
        end
      end
    end
  end
end
