module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableRepositories
        attr_reader :creatable, :updatable

        def initialize(organization:, metadata_repositories:)
          @organization = organization
          @metadata_repositories = metadata_repositories
          @creatable = []
          @updatable = []
        end

        def generate!
          # For Red Hat repositories or Custom Repositories in the metadata exclusively
          # Set up a 2 different list of importable root repositories
          # creatable: repos that are part of the metadata but not in the library.
          #         They are ready to be created
          # updatable: repo that are both in the metadata and library.
          #         These may contain updates to the repo and hence ready to be updated.
          @metadata_repositories.each do |repo|
            product = product_for_metadata_repo(repo)
            fail _("Unable to find product '%s' in organization '%s'" % [repo.product.label, @organization.name]) if product.blank?

            # TODO: is it valid to look up the root this way?
            root = product.root_repositories.find { |r| r.label == repo.label }
            #if product_repo_labels.include?([repo.product.label, repo.label])
            if root
              #root = ::Katello::RootRepository.find_by(product: product, label: repo.label)
              updatable << { repository: root, options: update_repo_params(repo) }
            elsif repo.redhat
              content = repo.content
              product_content = product_content_by_label(content.label)
              substitutions = {
                basearch: repo.arch,
                releasever: repo.minor
              }
              creatable << { product: product, content: product_content, substitutions: substitutions }
            else
              creatable << { repository: product.add_repo(create_repo_params(repo)) }
            end
          end
        end

        private

        def product_for_metadata_repo(repo)
          if repo.redhat && repo.product.cp_id
            @organization.products.includes(:root_repositories).find_by(cp_id: repo.product.cp_id)
          else
            @organization.products.includes(:root_repositories).find_by(label: repo.product.label)
          end
        end

        def product_content_by_label(content_label)
          ::Katello::Content.find_by_label(content_label)
        end

        def gpg_key_id(metadata_repo)
          if metadata_repo.gpg_key
            @organization.gpg_keys.find_by(name: metadata_repo.gpg_key.name).id
          end
        end

        def create_repo_params(metadata_repo)
          keys = [
            :name,
            :label,
            :description,
            :arch,
            :unprotected,
            :content_type,
            :checksum_type,
            :os_versions,
            :major,
            :minor,
            :download_policy,
            :mirroring_policy
          ]

          params = {}
          params[:gpg_key_id] = gpg_key_id(metadata_repo)

          keys.each do |key|
            params[key] = metadata_repo.send(key)
          end

          params
        end

        def update_repo_params(metadata_repo)
          keys = [
            :description,
            :arch,
            :unprotected,
            :checksum_type,
            :os_versions,
            :major,
            :minor,
            :download_policy,
            :mirroring_policy
          ]

          params = {}
          params[:gpg_key_id] = gpg_key_id(metadata_repo)

          keys.each do |key|
            value = metadata_repo.send(key)
            params[key] = value if value
          end

          params
        end
      end
    end
  end
end
