module Actions
  module Katello
    module RepositorySet
      class AvailableRepositories < Actions::AbstractAsyncTask
        def plan(product:, content_id:)
          results = []
          cdn_config = product.organization.cdn_configuration

          if ::Katello::Resources::CDN::CdnResource.redhat_cdn?(cdn_config.url)
            action = plan_action(ScanCdn, product, content_id)
            results = action.output[:results]
          else
            content = ::Katello::Content.find_by(cp_content_id: content_id)
            url = "#{cdn_config.url}/katello/api/v2/repository_sets?organization_id=1&search=(label = #{content.label})"
            client_cert = OpenSSL::X509::Certificate.new(cdn_config.ssl_cert_credential.content)
            client_key = OpenSSL::PKey::RSA.new(cdn_config.ssl_key_credential.content)
            response = RestClient::Request.execute(
              method: :get,
              url: url,
              ssl_client_cert: client_cert,
              ssl_client_key: client_key,
              headers: { accept: :json, content_type: :json },
              verify_ssl: OpenSSL::SSL::VERIFY_NONE
            )
            json_body = JSON.parse(response.body)
            repo_set = json_body['results'].first

            # now get available repositories when we know the upstream repo set ID
            url = "#{cdn_config.url}/katello/api/v2/repository_sets/#{repo_set['id']}/available_repositories?organization_id=1"
            response = RestClient::Request.execute(
              method: :get,
              url: url,
              headers: { accept: :json, content_type: :json },
              ssl_client_cert: client_cert,
              ssl_client_key: client_key,
              verify_ssl: OpenSSL::SSL::VERIFY_NONE
            )
            json_body = JSON.parse(response.body)
            results = json_body['results']
          end

          plan_self(results: results)
        end

        def run
          output[:results] = input[:results]
        end
      end
    end
  end
end
