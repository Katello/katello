module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableRepositories
        attr_accessor :creatable, :updatable, :organization, :metadata

        def initialize(organization:, metadata:)
          self.organization = organization
          self.metadata = metadata
          self.creatable = []
          self.updatable = []
        end

        def repositories_in_library
          return @repositories_in_library unless @repositories_in_library.blank?

          # fetch a list of [product, repo] pairs for every non-redhat library repo
          product_repos_in_library = Import.repositories_in_library(organization).custom.
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
          metadata_map = Import.metadata_map(metadata, custom_only: true)
          metadata_map.keys.each do |product_label, repo_label|
            product = Katello::Product.in_org(organization).find_by(label: product_label)
            fail _("Unable to find product '%s' in organization '%s'" % [product_label, organization.name]) if product.blank?
            params = metadata_map[[product_label, repo_label]]
            unless params[:gpg_key].blank?
              params[:gpg_key_id] = Import.create_or_update_gpg!(organization: organization,
                                                                 params: params[:gpg_key]).id
            end
            params = params.except(:redhat, :product, :gpg_key)
            if repositories_in_library.include? [product_label, repo_label]
              repo = ::Katello::RootRepository.find_by(product: product, label: repo_label)
              updatable << { repository: repo, options: params.except(:label, :name, :content_type) }
            else
              creatable << { repository: product.add_repo(params) }
            end
          end
        end
      end
    end
  end
end
