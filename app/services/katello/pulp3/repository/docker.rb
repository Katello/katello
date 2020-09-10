require 'pulp_container_client'

module Katello
  module Pulp3
    class Repository
      class Docker < ::Katello::Pulp3::Repository
        def relative_path
          repo.container_repository_name
        end

        def remote_options
          options = {url: root.url, upstream_name: root.docker_upstream_name}
          if root.docker_tags_whitelist&.any?
            options[:include_tags] = root.docker_tags_whitelist
          else
            options[:include_tags] = nil
          end
          common_remote_options.merge(options)
        end

        def secure_distribution_options(path)
          #we never need a content guard for docker, and pulp creates one behind the scenes,
          # so we have to make sure not to try to clear it out
          options = super
          options.delete(:content_guard)
          options
        end

        def mirror_remote_options
          {
            url: "https://#{SmartProxy.pulp_primary.pulp3_host!.downcase}",
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

        def create_version(options = {})
          api.repositories_api.add(repository_reference.repository_href,
                                   api.class.recursive_manage_class.new(content_units: options[:add_content_units]))
          api.repositories_api.remove(repository_reference.repository_href,
                                      api.class.recursive_manage_class.new(content_units: options[:remove_content_units]))
        end

        def add_content(content_unit_href)
          content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
          api.repositories_api.add(repository_reference.repository_href, content_units: content_unit_href)
        end

        def copy_units_recursively(unit_hrefs, clear_repo = false)
          tasks = []
          if clear_repo
            tasks << api.repositories_api.remove(repository_reference.repository_href,
                                                 api.class.recursive_manage_class.new(:content_units => ["*"]))
          end
          tasks << api.repositories_api.add(repository_reference.repository_href,
                                            api.class.recursive_manage_class.new(content_units: unit_hrefs))
          tasks
        end

        def copy_content_for_source(source_repository, options = {})
          filters = ContentViewDockerFilter.where(:id => options[:filter_ids])
          include_list_ids = []
          exclude_list_ids = []
          filters.each do |filter|
            if filter.inclusion
              include_list_ids += filter.content_unit_pulp_ids(source_repository)
            else
              exclude_list_ids += filter.content_unit_pulp_ids(source_repository)
            end
          end

          if include_list_ids.empty?
            copy_units_recursively(source_repository.docker_tags.pluck(:pulp_id).sort - exclude_list_ids, true)
          else
            copy_units_recursively(include_list_ids - exclude_list_ids, true)
          end
        end
      end
    end
  end
end
