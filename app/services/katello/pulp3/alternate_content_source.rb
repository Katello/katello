require "pulpcore_client"
module Katello
  module Pulp3
    class AlternateContentSource
      include Katello::Pulp3::ServiceCommon
      attr_accessor :acs
      attr_accessor :smart_proxy
      attr_accessor :repository

      def initialize(acs, smart_proxy, repository = nil)
        @acs = acs
        @smart_proxy = smart_proxy
        @repository = repository
      end

      def api
        @api ||= ::Katello::Pulp3::Repository.api(smart_proxy, @acs.content_type)
      end

      def generate_backend_object_name
        "#{acs.label}-#{smart_proxy.url}-#{rand(9999)}"
      end

      def smart_proxy_acs
        if acs.alternate_content_source_type == 'custom'
          ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
        else
          ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repository.id)
        end
      end

      def remote_options
        if repository.present?
          options = repository.backend_service(smart_proxy).remote_options
          options[:policy] = 'on_demand'
          return options
        end

        remote_options = {
          tls_validation: acs.verify_ssl,
          name: generate_backend_object_name,
          url: acs.base_url,
          policy: 'on_demand',
          proxy_url: acs.http_proxy&.url,
          proxy_username: acs.http_proxy&.username,
          proxy_password: acs.http_proxy&.password,
          total_timeout: Setting[:sync_connect_timeout]
        }
        if acs.content_type == ::Katello::Repository::FILE_TYPE && acs.subpaths.empty? && !remote_options[:url].end_with?('/PULP_MANIFEST')
          remote_options[:url] = acs.base_url + '/PULP_MANIFEST'
        end
        remote_options.merge!(username: acs&.upstream_username, password: acs&.upstream_password)
        remote_options.merge!(ssl_remote_options)
      end

      def ssl_remote_options
        if acs.custom?
          {
            client_cert: acs.ssl_client_cert&.content,
            client_key: acs.ssl_client_key&.content,
            ca_cert: acs.ssl_ca_cert&.content
          }
        end
      end

      def create_remote
        if smart_proxy_acs&.remote_href.nil?
          response = super
          smart_proxy_acs.update!(remote_href: response.pulp_href)
        end
      end

      def get_remote(href = smart_proxy_acs.remote_href)
        acs.base_url&.start_with?('uln') ? api.remotes_uln_api.read(href) : api.remotes_api.read(href)
      end

      def update_remote
        api.remotes_api.partial_update(smart_proxy_acs.remote_href, remote_options)
      end

      def delete_remote(href = smart_proxy_acs.remote_href)
        ignore_404_exception { remote_options[:url]&.start_with?('uln') ? api.remotes_uln_api.delete(href) : api.remotes_api.delete(href) } if href
      end

      def create
        if smart_proxy_acs&.alternate_content_source_href.nil?
          paths = acs.subpaths.deep_dup
          if acs.content_type == ::Katello::Repository::FILE_TYPE && acs.subpaths.present?
            paths = insert_pulp_manifest!(paths)
          end
          response = api.alternate_content_source_api.create(name: generate_backend_object_name, paths: paths,
                                                             remote: smart_proxy_acs.remote_href)
          smart_proxy_acs.update!(alternate_content_source_href: response.pulp_href)
          return response
        end
      end

      def read(href = smart_proxy_acs.alternate_content_source_href)
        api.alternate_content_source_api.read(href)
      end

      def update
        href = smart_proxy_acs.alternate_content_source_href
        paths = acs.subpaths.deep_dup
        if acs.content_type == ::Katello::Repository::FILE_TYPE && acs.subpaths.present?
          paths = insert_pulp_manifest!(paths)
        end
        api.alternate_content_source_api.update(href, name: generate_backend_object_name, paths: paths, remote: smart_proxy_acs.remote_href)
      end

      def delete_alternate_content_source
        href = smart_proxy_acs.alternate_content_source_href
        ignore_404_exception { api.alternate_content_source_api.delete(href) } if href
      end

      def refresh
        href = smart_proxy_acs.alternate_content_source_href
        # https://github.com/pulp/pulp_rpm/issues/2504
        api.alternate_content_source_api.refresh(href, 'placeholder')
      end

      private

      def insert_pulp_manifest!(subpaths)
        subpaths.map! do |subpath|
          if subpath.end_with?('/PULP_MANIFEST')
            subpath
          else
            subpath + '/PULP_MANIFEST'
          end
        end
      end
    end
  end
end
