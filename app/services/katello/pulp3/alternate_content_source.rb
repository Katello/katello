require "pulpcore_client"
module Katello
  module Pulp3
    class AlternateContentSource
      attr_accessor :acs
      attr_accessor :smart_proxy

      def initialize(acs, smart_proxy)
        @acs = acs
        @smart_proxy = smart_proxy
      end

      def api
        @api ||= ::Katello::Pulp3::Repository.api(smart_proxy, @acs.content_type)
      end

      def generate_backend_object_name
        "#{acs.label}-#{smart_proxy.url}-#{rand(9999)}"
      end

      def smart_proxy_acs
        ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
      end

      # TODO: can remote-related code be pulled out of the repository service classes?
      def remote_options
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
        # TODO: add /PULP_MANIFEST? like so?  The paths would also need /PULP_MANIFEST if there are any.
        #remote_options[:url] = acs.url + '/PULP_MANIFEST' if acs.content_type == ::Katello::Repository::FILE_TYPE && acs.subpaths.empty?
        # TODO: download concurrency?
        if !acs.upstream_username.blank? && !asc.upstream_password.blank?
          remote_options.merge!(username: acs.upstream_username,
                               password: asc.upstream_password)
        end
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

      # TODO: ULN? reformat_api_exception?
      def create_remote
        remote_file_data = api.remote_class.new(remote_options)
        response = api.remotes_api.create(remote_file_data)
        smart_proxy_acs.update!(remote_href: response.pulp_href)
        response
      end

      def delete_remote
        href = smart_proxy_acs.remote_href
        api.remotes_api.delete(href) if href
      end

      def create
        response = api.alternate_content_source_api.create(name: generate_backend_object_name, paths: acs.subpaths,
                                                           remote: smart_proxy_acs.remote_href)
        smart_proxy_acs.update!(alternate_content_source_href: response.pulp_href)
      end

      def delete
        href = smart_proxy_acs.alternate_content_source_href
        api.alternate_content_source_api.delete(href) if href
      end

      # TODO: ignore 404
      def delete_alternate_content_source
        href = smart_proxy_acs.alternate_content_source_href
        api.alternate_content_source_api.delete(href) if href
      end
    end
  end
end
