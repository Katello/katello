module Katello
  module Candlepin
    class RepositoryMapper
      attr_reader :product, :content, :substitutions

      def initialize(product, content, substitutions)
        @product = product
        @content = content
        @substitutions = prune_substitutions(substitutions.try(:with_indifferent_access), content.content_url)
      end

      def find_repository
        root = ::Katello::RootRepository.where(product_id: product.id,
                                    content_id: content.cp_content_id,
                                    minor: minor,
                                    arch: arch).first
        if root
          Katello::Repository.where(root: root,
                                    environment_id: product.organization.library.id).first

        end
      end

      def build_repository
        root = RootRepository.new(
          :product => product,
          :content_id => content.cp_content_id,
          :arch => arch,
          :major => major,
          :minor => minor,
          :name => name,
          :label => label,
          :url => feed_url,
          :content_type => katello_content_type,
          :unprotected => unprotected?,
          :download_policy => download_policy,
          :mirroring_policy => Katello::RootRepository::MIRRORING_POLICY_COMPLETE
        )

        Repository.new(:root => root,
                       :relative_path => relative_path,
                       :environment => product.organization.library,
                       :content_view_version => product.organization.library.default_content_view_version)
      end

      def validate!
        return if katello_content_type == Repository::OSTREE_TYPE || product.organization.cdn_configuration.airgapped?
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

      def prune_substitutions(subs, url)
        subs.select { |key, _| url.include?("$#{key}") }
      end

      def feed_url
        @feed_url ||= if product.cdn_resource&.respond_to?(:repository_url)
                        product.cdn_resource.repository_url(content_label: content.label)
                      else
                        product.repo_url(path)
                      end
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
        kickstart? || file? || suse?
      end

      def suse?
        content.content_type == Repository::YUM_TYPE && !!path.downcase.match(/suse/)
      end

      def file?
        content.content_type.downcase == 'file'
      end

      def kickstart?
        content.content_type.downcase == 'kickstart'
      end

      def download_policy
        if katello_content_type == Repository::YUM_TYPE
          Setting[:default_redhat_download_policy]
        else
          ""
        end
      end
    end
  end
end
