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
        if !acs.upstream_username.blank? && !acs.upstream_password.blank?
          remote_options.merge!(username: acs.upstream_username,
                               password: acs.upstream_password)
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

      # TODO: ULN?
      def create_remote
        if smart_proxy_acs&.remote_href.nil?
          reformat_api_exception do
            remote_file_data = api.remote_class.new(remote_options)
            response = api.remotes_api.create(remote_file_data)
            smart_proxy_acs.update!(remote_href: response.pulp_href)
          end
        end
      end

      # TODO: ULN?
      def create_test_remote
        test_remote_options = remote_options
        test_remote_options[:name] = test_remote_name
        remote_file_data = api.remote_class.new(test_remote_options)

        reformat_api_exception do
          response = api.remotes_api.create(remote_file_data)
          #delete is async, but if its not properly deleted, orphan cleanup will take care of it later
          delete_remote(response.pulp_href)
        end
      end

      def test_remote_name
        "test_remote_#{SecureRandom.uuid}"
      end

      def update_remote
        api.remotes_api.partial_update(smart_proxy_acs.remote_href, remote_options)
      end

      # TODO: ignore 404?
      def delete_remote
        href = smart_proxy_acs.remote_href
        api.remotes_api.delete(href) if href
      end

      def create
        if smart_proxy_acs&.alternate_content_source_href.nil?
          response = api.alternate_content_source_api.create(name: generate_backend_object_name, paths: acs.subpaths,
                                                             remote: smart_proxy_acs.remote_href)
          smart_proxy_acs.update!(alternate_content_source_href: response.pulp_href)
          return response
        end
      end

      def update
        href = smart_proxy_acs.alternate_content_source_href
        api.alternate_content_source_api.update(href, name: generate_backend_object_name, paths: acs.subpaths,
                                                remote: smart_proxy_acs.remote_href)
      end

      def delete
        href = smart_proxy_acs.alternate_content_source_href
        api.alternate_content_source_api.delete(href) if href
      end

      # TODO: ignore 404?
      def delete_alternate_content_source
        href = smart_proxy_acs.alternate_content_source_href
        api.alternate_content_source_api.delete(href) if href
      end

      def reformat_api_exception
        yield
      rescue api.client_module::ApiError => exception
        body = JSON.parse(exception.response_body) rescue body
        body = body.values.join(',') if body.respond_to?(:values)
        raise ::Katello::Errors::Pulp3Error, body
      end
    end
  end
end
