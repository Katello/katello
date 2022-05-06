module Actions
  module Katello
    module Repository
      class SyncDebErrata < Actions::EntryAction
        def plan(repo, force = false)
          plan_self(repo_id: repo.id, force_download: force)
        end

        def run
          repo = ::Katello::Repository.find(input[:repo_id]).root
          proxy = repo.http_proxy
          params = {}
          params['releases'] = repo.deb_releases.split(' ').map { |comp| comp.split('/')[0] }.join(',') if repo.deb_releases
          params['components'] = repo.deb_components.split(' ').join(',') if repo.deb_components
          params['architectures'] = repo.deb_architectures.split(' ').join(',') if repo.deb_architectures
          RestClient::Request.execute(
            method: :get,
            url: repo.deb_errata_url,
            proxy: proxy&.full_url,
            headers: {
              params: params,
              'If-None-Match' => input[:force_download] ? nil : repo.deb_errata_url_etag
            }
          ) do |response, _request, _result, &block|
            case response.code
            when 200
              output[:etag] = response.headers[:etag] || ''
              output[:modified] = true
              output[:data] = response.body
            when 304 # not modified
              output[:modified] = false
            else
              response.return!(&block)
            end
          end
        rescue => e
          raise "Error while fetching errata information (#{e.to_s})"
        end

        # rubocop:disable Metrics/MethodLength
        def finalize
          if output[:modified]
            repo = ::Katello::Repository.find(input[:repo_id])
            erratum_list = JSON.parse(output[:data])
            erratum_list.each do |data|
              erratum = ::Katello::Erratum.find_or_initialize_by(errata_id: data['name'])
              erratum.errata_id = data['name']
              erratum.pulp_id = data['name']
              erratum.title = data['title']
              erratum.summary = data['summary'] || ''
              erratum.description = data['description']
              erratum.issued = data['issued']
              erratum.updated = data['updated'] || data['issued']
              erratum.severity = data['severity'] || ''
              erratum.solution = data['solution'] || ''
              erratum.reboot_suggested = data['reboot_suggested'] || false
              erratum.errata_type = 'security'
              erratum.save!
              data['cves']&.each do |cve|
                erratum.cves.find_or_initialize_by(cve_id: cve)
              end
              data['dbts_bugs']&.each do |dbts_bug|
                erratum.dbts_bugs.find_or_initialize_by(bug_id: dbts_bug)
              end
              data['packages']&.each do |package|
                affected_deb = erratum.deb_packages.find_or_initialize_by(name: package['name'], release: package['release'])
                affected_deb.version = package['version']
                affected_deb.save!
              end
              erratum.repositories |= [repo]
              erratum.save!
            end
            repo.root.update(deb_errata_url_etag: output[:etag])
          end
        end

        def humanized_output
          output.dup.update(data: 'Trimmed')
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
