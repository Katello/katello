require 'pulp_container_client'

module Katello
  module Pulp3
    class Repository
      class Docker < ::Katello::Pulp3::Repository
        def relative_path
          repo.container_repository_name
        end

        # TODO: Evaluate shared distribution reconciliation for other content types; preserve their recovery behavior.
        def refresh_distributions
          ref = distribution_reference
          return update_distribution if ref && read_distribution(ref.href)

          # A missing reference cannot prove ownership of a distribution at the target path.
          # Leave a stale reference in place until creation succeeds.
          begin
            create_distribution(relative_path)
          rescue api.client_module::ApiError => e
            if e.message.include?("\"base_path\":[\"This field must be unique.\"]")
              raise ::Katello::Errors::Pulp3Error,
                    _("A Pulp distribution already exists at '%{path}' but is not tracked by Katello. Remove or move the existing distribution, or contact an administrator.") % {path: repo.container_repository_name}
            elsif self.class.distribution_overlap_error?(e.message)
              raise ::Katello::Errors::Pulp3Error, ::Katello::Validators::ContainerPathOverlapValidator.late_overlap_message(repo)
            else
              raise e
            end
          end
        end

        def save_distribution_references(hrefs)
          hrefs.each do |href|
            dist = read_distribution(href)
            fail _("The Pulp distribution could not be found after the operation completed.") unless dist

            ref = distribution_reference
            if ref && ref.href != href && read_distribution(ref.href)
              fail _("The repository references a different existing Pulp distribution.")
            end

            guard_href = dist.content_guard
            guard_prn = self.class.build_prn(guard_href, 'certguard', 'rhsmcertguard') if guard_href&.include?('/contentguards/certguard/rhsm/')
            attributes = {
              href: href,
              path: dist.base_path,
              prn: dist.prn,
              content_guard_href: guard_href,
              content_guard_prn: guard_prn,
            }
            if ref
              ref.update!(attributes)
            else
              DistributionReference.where(attributes.merge(repository_id: repo.id)).first_or_create!
            end
          end
        end

        def partial_repo_path
          ''
        end

        def remote_options
          options = {url: root.url, upstream_name: root.docker_upstream_name, policy: root.download_policy}
          if root.include_tags&.any?
            options[:include_tags] = root.include_tags
          else
            options[:include_tags] = nil
          end
          if root.exclude_tags&.any?
            options[:exclude_tags] = root.exclude_tags
          else
            options[:exclude_tags] = nil
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
          super.merge(
            {
              url: "https://#{SmartProxy.pulp_primary.pulp3_host!.downcase}",
              upstream_name: repo.container_repository_name,
            }
          )
        end

        def distribution_options(path)
          options = {
            base_path: path,
            name: "#{generate_backend_object_name}",
          }
          if root.is_container_push && repo.in_default_view?
            options[:repository] = repository_reference.repository_href
          else
            options[:repository_version] = repo.version_href
          end
          options
        end

        def create_version(options = {})
          api.repositories_api.add(repository_reference.repository_href,
                                   api.class.recursive_manage_class.new(content_units: options[:add_content_units]))
          api.repositories_api.remove(repository_reference.repository_href,
                                      api.class.recursive_manage_class.new(content_units: options[:remove_content_units]))
        end

        def tag_manifest(name, digest)
          api.repositories_api.tag(repository_reference.repository_href,
                                   api.class.tag_image_class.new(tag: name, digest: digest))
        end

        def add_content(content_unit_href)
          content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
          api.repositories_api.add(repository_reference.repository_href, content_units: content_unit_href)
        rescue api.client_module::ApiError => e
          if e.message.include? 'Could not find the following content units'
            raise ::Katello::Errors::Pulp3Error, "Content units that do not exist in Pulp were requested to be copied."\
              " Please run `foreman-rake katello:delete_orphaned_content` to fix the following repository: #{repository_reference.root_repository.name}. Original error: #{e.message}"
          else
            raise e
          end
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

        def legacy_container_push?
          root.is_container_push && repository_reference&.repository_href&.include?('/container/container-push/')
        end
      end
    end
  end
end
