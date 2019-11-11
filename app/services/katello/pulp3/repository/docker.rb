require 'pulp_docker_client'

module Katello
  module Pulp3
    class Repository
      class Docker < ::Katello::Pulp3::Repository
        def remote_options
          options = {url: root.url, upstream_name: root.docker_upstream_name}
          if root.docker_tags_whitelist && root.docker_tags_whitelist.any?
            options[:whitelist_tags] = root.docker_tags_whitelist
          else
            options[:whitelist_tags] = nil
          end
          common_remote_options.merge(options)
        end

        def mirror_remote_options
          {
            url: "https://#{SmartProxy.pulp_master.pulp3_host!.downcase}",
            upstream_name: repo.container_repository_name
          }
        end

        def distribution_options(path)
          {
            base_path: path,
            repository_version: repo.version_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def copy_units_recursively(unit_hrefs, clear_repo = false)
          tasks = []
          if clear_repo
            tasks << create_version(:remove_content_units => ["*"])
          end
          tasks << api.recursive_add_api.create(api.class.recursive_manage_class.new(repository: repository_reference.repository_href,
                                                                       content_units: unit_hrefs))
          tasks
        end

        def copy_content_for_source(source_repository, options = {})
          filters = ContentViewDockerFilter.where(:id => options[:filter_ids])
          whitelist_ids = []
          blacklist_ids = []
          filters.each do |filter|
            if filter.inclusion
              whitelist_ids += filter.content_unit_pulp_ids(source_repository)
            else
              blacklist_ids += filter.content_unit_pulp_ids(source_repository)
            end
          end

          if whitelist_ids.empty?
            copy_units_recursively(source_repository.docker_tags.pluck(:pulp_id).sort - blacklist_ids, true)
          else
            copy_units_recursively(whitelist_ids - blacklist_ids, true)
          end
        end
      end
    end
  end
end
