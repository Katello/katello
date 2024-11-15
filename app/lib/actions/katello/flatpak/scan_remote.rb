require 'cgi'
require 'uri'
module Actions
  module Katello
    module Flatpak
      class ScanRemote < Actions::EntryAction
        def plan(remote, _args = {})
          plan_self({:remote_id => remote.id, :url => format_url(remote.url)})
        end

        def run
          remote = ::Katello::FlatpakRemote.find(input[:remote_id])
          results = fetch_results(input[:url])
          remote.update!(registry_url: results['Registry']) unless remote.registry_url
          repositories = results['Results']
          repositories.each do |repository|
            remote_repository = remote.remote_repositories.find_or_initialize_by(name: repository['Name'])
            remote_repository.save!
            repository['Images'].each do |image|
              remote_repository_manifest = remote_repository.manifests.find_or_initialize_by(digest: image['Digest'])
              remote_repository_manifest.flatpak_remote_repository_id = remote_repository.id
              remote_repository_manifest.name = image['Labels']['name']
              remote_repository_manifest.tags = image['Tags']
              remote_repository_manifest.application = image['Labels']['org.flatpak.ref'].start_with?('app/')
              remote_repository_manifest.flatpak_ref = image['Labels']['org.flatpak.ref']
              remote_repository_manifest.runtime = extract_runtime_from_metadata(image['Labels']['org.flatpak.metadata'])
              remote_repository_manifest.save!
            end
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def fetch_results(url)
          request_params = {
            method: :get,
            headers: { accept: :json },
            url: url,
          }
          response = RestClient::Request.execute(request_params)
          JSON.parse(response)
        end

        def extract_runtime_from_metadata(metadata)
          match = metadata.match(/^runtime=(.*)$/)
          match ? "runtime/" + match[1] : nil
        end

        def format_url(url)
          unless url.ends_with?('/index/static?')
            url += '/index/static?'
          end
          params = [
            ['tag', 'latest'],
            ['label:org.flatpak.ref:exists', '1'],
          ]
          encoded_params = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }
          "#{url}#{encoded_params.sort.join('&')}"
        end
      end
    end
  end
end
