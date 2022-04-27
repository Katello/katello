require 'pulp_deb_client'

module Katello
  module Pulp3
    class Repository
      class Apt < ::Katello::Pulp3::Repository
        SIGNING_SERVICE_NAME = 'katello_deb_sign'.freeze

        UNIT_LIMIT = 10_000

        def remote_options
          deb_remote_options = {
            policy: root.download_policy,
            distributions: root.deb_releases
          }
          deb_remote_options[:components] = root.deb_components.present? ? root.deb_components : nil
          deb_remote_options[:architectures] = root.deb_architectures.present? ? root.deb_architectures : nil

          if root.url.blank?
            deb_remote_options[:url] = nil
          end

          deb_remote_options[:gpgkey] = root.gpg_key.present? ? root.gpg_key.content : nil

          common_remote_options.merge(deb_remote_options)
        end

        def mirror_remote_options
          policy = smart_proxy.download_policy

          if smart_proxy.download_policy == SmartProxy::DOWNLOAD_INHERIT
            policy = repo.root.download_policy
          end

          {
            policy: policy,
            distributions: "#{repo.deb_releases}#{ ' default' unless repo.deb_releases&.split(' ')&.include? 'default'}"
          }
        end

        def publication_options(repository_version)
          ss = api.signing_services_api.list(name: SIGNING_SERVICE_NAME).results
          popts = super(repository_version)
          popts.merge!(
            {
              structured: true, # publish real suites (e.g. 'stable')
              simple: true # publish all into 'default'-suite
            }
          )
          popts[:signing_service] = ss[0].pulp_href if ss && ss.length == 1
          popts
        end

        def mirror_publication_options
          {
            # Since we are synchronizing the "default" distribution from the simple publisher on the server,
            # it will be included in the structured publish. Therefore, we MUST NOT use the simple publisher
            # on the proxy, since this would collide!
            #simple: true,
            structured: true # publish real suites (e.g. 'stable')
          }
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def partial_repo_path
          "/pulp/deb/#{repo.relative_path}/".sub('//', '/')
        end

        def multi_copy_units(repo_id_map, dependency_solving)
          tasks = []

          if repo_id_map.values.pluck(:content_unit_hrefs).flatten.any?
            data = PulpDebClient::Copy.new
            #FIXME not yet supported
            data.dependency_solving = false
            data.config = []
            repo_id_map.each do |source_repo_ids, dest_repo_id_map|
              dest_repo = ::Katello::Repository.find(dest_repo_id_map[:dest_repo])
              dest_repo_href = ::Katello::Pulp3::Repository::Apt.new(dest_repo, SmartProxy.pulp_primary).repository_reference.repository_href
              content_unit_hrefs = dest_repo_id_map[:content_unit_hrefs]
              source_repo_ids.each do |source_repo_id|
                source_repo_version = ::Katello::Repository.find(source_repo_id).version_href
                config = { source_repo_version: source_repo_version, dest_repo: dest_repo_href, content: content_unit_hrefs }
                config[:dest_base_version] = dest_repo_id_map[:base_version] if dest_repo_id_map[:base_version]
                data.config << config
              end
            end
            tasks << copy_content_chunked(data)
          else
            tasks << remove_all_content_from_mapping(repo_id_map)
          end
          tasks.flatten
        end

        def copy_api_data_dup(data)
          data_dup = PulpDebClient::Copy.new
          data_dup.dependency_solving = data.dependency_solving
          data_dup.config = []
          data.config.each do |repo_config|
            config_hash = {
              source_repo_version: repo_config[:source_repo_version],
              dest_repo: repo_config[:dest_repo],
              content: []
            }
            config_hash[:dest_base_version] = repo_config[:dest_base_version] if repo_config[:dest_base_version]
            data_dup.config << config_hash
          end
          data_dup
        end

        def copy_content_chunked(data)
          tasks = []
          # Don't chunk if there aren't enough content units
          if data.config.sum { |repo_config| repo_config[:content].size } <= UNIT_LIMIT
            return api.copy_api.copy_content(data)
          end

          unit_copy_counter = 0
          i = 0
          leftover_units = data.config.first[:content].deep_dup

          # Copy data and clear its content fields
          data_dup = copy_api_data_dup(data)

          while i < data_dup.config.size
            # Copy all units within repo or only some?
            if leftover_units.length < UNIT_LIMIT - unit_copy_counter
              copy_amount = leftover_units.length
            else
              copy_amount = UNIT_LIMIT - unit_copy_counter
            end

            data_dup.config[i][:content] = leftover_units.pop(copy_amount)
            unit_copy_counter += copy_amount
            if unit_copy_counter != 0
              tasks << api.copy_api.copy_content(data_dup)
              unit_copy_counter = 0
            end

            if leftover_units.empty?
              # Nothing more to copy -- clear current config's content
              data_dup.config[i][:content] = []
              i += 1
              # Fetch unit list for next data config
              leftover_units = data.config[i][:content].deep_dup unless i == data_dup.config.size
            end
          end

          tasks
        end

        def remove_all_content_from_mapping(repo_id_map)
          tasks = []
          repo_id_map.each do |_source_repo_ids, dest_repo_id_map|
            dest_repo = ::Katello::Repository.find(dest_repo_id_map[:dest_repo])
            dest_repo_href = ::Katello::Pulp3::Repository::Apt.new(dest_repo, SmartProxy.pulp_primary).repository_reference.repository_href
            tasks << remove_all_content_from_repo(dest_repo_href)
          end
          tasks
        end

        def copy_units(source_repository, content_unit_hrefs, dependency_solving)
          tasks = []

          if content_unit_hrefs.sort!.any?
            data = PulpDebClient::Copy.new
            data.config = [{
              source_repo_version: source_repository.version_href,
              dest_repo: repository_reference.repository_href,
              dest_base_version: 0,
              content: content_unit_hrefs
            }]
            #FIXME not yet supported
            data.dependency_solving = false
            tasks << api.copy_api.copy_content(data)
          else
            tasks << remove_all_content
          end
          tasks
        end

        def remove_all_content_from_repo(repo_href)
          data = PulpDebClient::RepositoryAddRemoveContent.new(
            remove_content_units: ['*'])
          api.repositories_api.modify(repo_href, data)
        end

        def remove_all_content
          data = PulpDebClient::RepositoryAddRemoveContent.new(
            remove_content_units: ['*'])
          api.repositories_api.modify(repository_reference.repository_href, data)
        end

        def copy_content_for_source
          # TODO
          fail NotImplementedError
        end

        def regenerate_applicability
          # TODO
          fail NotImplementedError
        end
      end
    end
  end
end
