module Katello
  module Pulp3
    module ContentViewVersion
      class ImportableRepositories
        attr_reader :creatable, :updatable

        def initialize(organization:,
                       metadata_repositories:,
                       syncable_format: false,
                       path: nil)
          @organization = organization
          @metadata_repositories = metadata_repositories
          @creatable = []
          @updatable = []
          @syncable_format = syncable_format
          @path = path
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

            root = product.root_repositories.find do |r|
              if repo.content&.id && repo.redhat
                r.content.cp_content_id == repo.content.id &&
                  r.arch == repo.arch &&
                  r.major == repo.major &&
                  r.minor == repo.minor
              else
                r.label == repo.label
              end
            end

            if root
              updatable << { repository: root, options: update_repo_params(repo) }
            elsif repo.redhat
              product_content = fetch_product_content(repo.content, product)
              substitutions = {
                basearch: repo.arch,
                releasever: repo.minor
              }
              creatable << { product: product,
                             content: product_content,
                             substitutions: substitutions,
                             override_url: fetch_feed_url(repo)
                           }
            else
              creatable << { repository: product.add_repo(create_repo_params(repo, product)) }
            end
          end
        end

        private

        def find_unique_name(metadata_repo, product)
          name = metadata_repo.name
          i = 1
          while product.root_repositories.where(name: name).exists?
            name = "#{metadata_repo.name} #{i}"
            i += 1
          end
          name
        end

        def product_for_metadata_repo(repo)
          if repo.redhat && repo.product.cp_id
            @organization.products.includes(:root_repositories).find_by(cp_id: repo.product.cp_id)
          else
            @organization.products.includes(:root_repositories).find_by(label: repo.product.label)
          end
        end

        def fetch_product_content(content_metadata, product)
          query = ::Katello::Content.joins(:product_contents).where("#{Katello::ProductContent.table_name}.product_id": product.id)
          table_name = Katello::Content.table_name
          if content_metadata&.id
            query.find_by("#{table_name}.cp_content_id": content_metadata.id)
          else
            query.find_by("#{table_name}.label": content_metadata.label)
          end
        end

        def gpg_key_id(metadata_repo)
          if metadata_repo.gpg_key
            @organization.gpg_keys.find_by(name: metadata_repo.gpg_key.name).id
          end
        end

        def create_repo_params(metadata_repo, product)
          keys = [
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

          params = { name: find_unique_name(metadata_repo, product) }
          params[:gpg_key_id] = gpg_key_id(metadata_repo)
          keys.each do |key|
            params[key] = metadata_repo.send(key)
          end
          url = fetch_feed_url(metadata_repo)
          params[:url] = url if url
          params
        end

        def fetch_feed_url(metadata_repo)
          return unless @syncable_format
          uri = URI(@path)
          if uri.scheme.blank? || uri.scheme == "file"
            "file://#{uri.path.chomp('/')}#{metadata_repo.content.url}"
          else
            "#{@path.chomp('/')}#{metadata_repo.content.url}"
          end
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
          url = fetch_feed_url(metadata_repo)
          params[:url] = url if url
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
