module Katello
  class Candlepin::Content
    attr_accessor :name, :id, :type, :label, :vendor, :contentUrl, :gpgUrl, :modifiedProductIds

    def initialize(params = {})
      load_attributes(params)
    end

    def self.find(id)
      found = Resources::Candlepin::Content.get(id)
      Candlepin::Content.new(found)
    end

    def create
      created = Resources::Candlepin::Content.create self
      load_attributes(created)

      self
    end

    def destroy
      Resources::Candlepin::Content.destroy(@id)
    end

    def update(params = {})
      return self if params.empty?

      updated = Resources::Candlepin::Content.update(params.merge(:id => @id))
      load_attributes(updated)

      self
    end

    def load_attributes(params)
      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    class RepositoryMapper
      attr_reader :product, :content, :substitutions

      def initialize(product, content, substitutions)
        @product = product
        @content = content
        @substitutions = substitutions
      end

      def find_repository
        ::Katello::Repository.where(product_id: product.id,
                                    environment_id: product.organization.library.id,
                                    pulp_id: pulp_id).first
      end

      def build_repository
        certificate_and_key = get_certificate_and_key(product, @content.modifiedProductIds)

        repository = Repository.new(
          :environment => product.organization.library,
          :product => product,
          :pulp_id => pulp_id,
          :cp_label => content.label,
          :content_id => content.id,
          :arch => arch,
          :major => major,
          :minor => minor,
          :relative_path => relative_path,
          :name => name,
          :label => label,
          :url => feed_url,
          :feed_ca => ca,
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
        substitutor.valid_substitutions(content, substitutions)
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

      def pulp_id
        product.repo_id(name)
      end

      def path
        substitutions.inject(content.contentUrl) do |url, (key, value)|
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
        kickstart? ? 'yum' : content.type
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
        content.type.downcase == 'file'
      end

      def kickstart?
        content.type.downcase == 'kickstart'
      end

      def download_policy
        if katello_content_type == Repository::YUM_TYPE
          Setting[:default_download_policy]
        else
          ""
        end
      end

      def ca
        File.read(::Katello::Resources::CDN::CdnResource.ca_file)
      end
    end

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
        @registries ||= product.cdn_resource.get_docker_registries(content.contentUrl)
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
          Rails.logger.error("Docker registry with pulp_id #{container_registry_name} was not found at #{content.contentUrl}")
          fail _("Docker repository not found")
        end
        ::Katello::Repository.new(:environment => product.organization.library,
                                 :product => product,
                                 :pulp_id => pulp_id,
                                 :cp_label => content.label,
                                 :content_id => content.id,
                                 :relative_path => relative_path,
                                 :name => name,
                                 :docker_upstream_name => registry["name"],
                                 :label => label,
                                 :url => feed_url,
                                 :feed_ca => ca,
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

      def pulp_id
        product.repo_id(content.name, nil, registry['name'])
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
        ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(product.organization.library, content.contentUrl)
      end

      def ca
        File.read(::Katello::Resources::CDN::CdnResource.ca_file)
      end
    end
  end
end
