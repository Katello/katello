module Katello
  module Candlepin
    class DockerRepositoryMapper
      attr_reader :product, :content
      attr_accessor :container_registry_name, :registries, :registry_repo
      def initialize(product, content, container_registry_name = nil)
        @product = product
        @content = content
        @container_registry_name = container_registry_name
      end

      def registry
        validate!
        @registries ||= product.cdn_resource.get_docker_registries(content.content_url)
        @registry_repo ||= registries.detect do |reg|
          reg['name'] == @container_registry_name
        end
      end

      def find_repository
        ::Katello::Repository.where(product_id: product.id,
                                    environment_id: product.organization.library.id,
                                    docker_upstream_name: container_registry_name).first
      end

      def build_repository
        unless registry
          Rails.logger.error("Docker registry with pulp_id #{container_registry_name} was not found at #{content.content_url}")
          fail _("Docker repository not found")
        end
        ::Katello::Repository.new(:environment => product.organization.library,
                                 :product => product,
                                 :content_id => content.cp_content_id,
                                 :relative_path => relative_path,
                                 :name => name,
                                 :docker_upstream_name => registry["name"],
                                 :label => label,
                                 :url => feed_url,
                                 :feed_ca => ::Katello::Repository.feed_ca_cert(feed_url),
                                 :feed_cert => product.certificate,
                                 :feed_key => product.key,
                                 :content_type => ::Katello::Repository::DOCKER_TYPE,
                                 :preserve_metadata => true, #preserve repo metadata when importing from cp
                                 :unprotected => true,
                                 :content_view_version => product.organization.library.default_content_view_version)
      end

      def validate!
        fail _("Registry name cannot be blank") if @container_registry_name.blank?
      end

      def name
        "#{content.name} - (#{registry['name']})"
      end

      def feed_url
        cdn_uri = URI.parse(product.provider.repository_url)
        docker_repo_uri =  URI.parse(registry["url"])
        docker_repo_uri =  URI.parse("#{cdn_uri.scheme}://#{registry['url']}") unless docker_repo_uri.host
        "#{docker_repo_uri.scheme}://#{docker_repo_uri.host}:#{docker_repo_uri.port}"
      end

      def label
        ::Katello::Util::Model.labelize(name)
      end

      def katello_content_type
        ::Katello::Repository::DOCKER_TYPE
      end

      def relative_path
        ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(product.organization.library, content.content_url)
      end
    end
  end
end
