module Katello
  module Pulp3
    module ContentViewVersion
      class MetadataMap
        class MetadataContentView < OpenStruct; end

        class MetadataContentViewVersion < OpenStruct; end

        class MetadataProduct < OpenStruct; end

        class MetadataRepository < OpenStruct; end

        class MetadataGpgKey < OpenStruct; end

        class MetadataRepositoryContent < OpenStruct; end

        attr_reader :toc,
                    :products,
                    :repositories,
                    :gpg_keys,
                    :content_view,
                    :content_view_version,
                    :from_content_view_version

        def initialize(metadata:)
          @toc = metadata[:toc]
          @products = parse_products(metadata[:products]) if metadata[:products]
          @repositories = parse_repositories(metadata[:repositories]) if metadata[:repositories]
          @content_view = parse_content_view(metadata[:content_view]) if metadata[:content_view]
          @content_view_version = parse_content_view_version(metadata[:content_view_version]) if metadata[:content_view_version]
          @from_content_view_version = parse_content_view_version(metadata[:from_content_view_version]) if metadata[:from_content_view_version]
          @gpg_keys = parse_gpg_keys(metadata[:gpg_keys]) if metadata[:gpg_keys]
        end

        private

        def parse_gpg_keys(gpg_keys)
          gpg_keys.values.map do |g|
            MetadataGpgKey.new(
              name: g[:name],
              content_type: g[:content_type],
              content: g[:content]
            )
          end
        end

        def parse_content_view(content_view)
          MetadataContentView.new(
            name: content_view['name'],
            label: content_view['label'],
            description: content_view['description'],
            generated_for: content_view['generated_for']
          )
        end

        def parse_products(products)
          products.values.map do |p|
            MetadataProduct.new(
              name: p[:name],
              label: p[:label],
              cp_id: p[:cp_id],
              description: p[:description],
              gpg_key: gpg_key_for_product(p),
              redhat: ::Foreman::Cast.to_bool(p[:redhat])
            )
          end
        end

        def parse_content_view_version(version)
          MetadataContentViewVersion.new(
            major: version[:major],
            minor: version[:minor],
            description: version[:description]
          )
        end

        def parse_repositories(repositories)
          repositories.map do |pulp_name, repo|
            MetadataRepository.new(
              pulp_name: pulp_name,
              name: repo[:name],
              label: repo[:label],
              description: repo[:description],
              arch: repo[:arch],
              content_type: repo[:content_type],
              unprotected: repo[:unprotected],
              checksum_type: repo[:checksum_type],
              os_versions: repo[:os_versions],
              major: repo[:major],
              minor: repo[:minor],
              download_policy: repo[:download_policy],
              mirroring_policy: repo[:mirroring_policy],
              redhat: repo[:redhat],
              product: product_for_repo(repo),
              gpg_key: gpg_key_for_repo(repo),
              content: repo[:content] ? MetadataRepositoryContent.new(id: repo[:content][:id], label: repo[:content][:label]) : nil
            )
          rescue => e
            raise _("Invalid repository in the metadata %{repo} error=%{error}") % { repo: repo, error: e.message }
          end
        end

        def gpg_key_for_repo(repo)
          @gpg_keys.find { |g| g.name == repo[:gpg_key][:name] } if repo[:gpg_key].present?
        end

        def gpg_key_for_product(product)
          @gpg_keys.find { |g| g.name == product[:gpg_key][:name] } if product[:gpg_key].present?
        end

        def product_for_repo(repo)
          @products.find { |p| p.label == repo[:product][:label] }
        end
      end
    end
  end
end
