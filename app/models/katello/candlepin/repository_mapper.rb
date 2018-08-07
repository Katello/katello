module Katello
  module Candlepin
    class RepositoryMapper
      attr_reader :product, :content, :substitutions

      def initialize(product, content, substitutions)
        @product = product
        @content = content
        @substitutions = substitutions.try(:with_indifferent_access)
      end

      def find_repository
        ::Katello::Repository.where(product_id: product.id,
                                    content_id: content.cp_content_id,
                                    environment_id: product.organization.library.id,
                                    minor: minor,
                                    arch: arch).first
      end

      def build_repository
        certificate_and_key = get_certificate_and_key(product, @content.modified_product_ids(product.organization))

        repository = Repository.new(
          :environment => product.organization.library,
          :product => product,
          :content_id => content.cp_content_id,
          :arch => arch,
          :major => major,
          :minor => minor,
          :relative_path => relative_path,
          :name => name,
          :label => label,
          :url => feed_url,
          :feed_ca => ::Katello::Repository.feed_ca_cert(feed_url),
          :feed_cert => certificate_and_key[:cert],
          :feed_key => certificate_and_key[:key],
          :content_type => katello_content_type,
          :preserve_metadata => true, #preserve repo metadata when importing from cp
          :unprotected => unprotected?,
          :download_policy => download_policy,
          :mirror_on_sync => true,
          :content_view_version => product.organization.
                                  library.default_content_view_version
        )

        repository
      end

      def get_certificate_and_key(product, modified_product_ids = [])
        modified_product_ids.each do |modified_product_id|
          modified_product = Product.where(:cp_id => modified_product_id).first
          product = modified_product if modified_product &&
                                        modified_product.certificate &&
                                        modified_product.key
        end
        {:cert => product.certificate, :key => product.key}
      end

      def validate!
        return if katello_content_type == Repository::OSTREE_TYPE
        substitutor.validate_substitutions(content, substitutions)
      end

      def substitutor
        product.cdn_resource.substitutor
      end

      def name
        sorted_substitutions = substitutions.sort_by { |k, _| k.to_s }.map(&:last)
        repo_name_parts = [content.name,
                           sorted_substitutions].flatten.compact
        repo_name_parts.join(" ").gsub(/[^a-z0-9\-\._ ]/i, "")
      end

      def path
        substitutions.inject(content.content_url) do |url, (key, value)|
          url.gsub("$#{key}", value)
        end
      end

      def relative_path
        ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(product.organization.library, path)
      end

      def feed_url
        product.repo_url(path)
      end

      def arch
        substitutions[:basearch] || "noarch"
      end

      def label
        ::Katello::Util::Model.labelize(name)
      end

      def version
        ::Katello::Resources::CDN::Utils.parse_version(substitutions[:releasever])
      end

      def major
        version[:major]
      end

      def minor
        version[:minor]
      end

      def content_type
        kickstart? ? 'yum' : content.content_type
      end

      def katello_content_type
        if content_type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
          ::Katello::Repository::DOCKER_TYPE
        else
          content_type
        end
      end

      def unprotected?
        kickstart? || file?
      end

      def file?
        content.content_type.downcase == 'file'
      end

      def kickstart?
        content.content_type.downcase == 'kickstart'
      end

      def download_policy
        if katello_content_type == Repository::YUM_TYPE
          Setting[:default_download_policy]
        else
          ""
        end
      end
    end
  end
end
