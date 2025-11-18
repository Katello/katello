module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::EntryAction
        def plan(repository, options = {})
          root = repository.root
          return if root.is_container_push && repository.library_instance?
          action_subject(repository)
          repository.check_ready_to_act!
          source_repository = options.fetch(:source_repository, nil)
          source_repository ||= repository.target_repository if repository.link?
          smart_proxy = options.fetch(:smart_proxy, SmartProxy.pulp_primary)
          matching_content = options.fetch(:matching_content, false)
          force_publication = options.fetch(:force_publication, false)

          plan_action(Pulp3::Orchestration::Repository::GenerateMetadata,
                        repository, smart_proxy,
                        :force_publication => force_publication,
                        :source_repository => source_repository,
                        :matching_content => matching_content)

          if repository.deb? && repository.content && !repository.content.content_url.end_with?(repository.deb_content_url_options)
            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        owner:           repository.organization.label,
                        repository_id:   repository.id,
                        name:            root.name,
                        type:            root.content_type,
                        arches:          root.format_arches,
                        label:           repository.content.label,
                        content_url:     root.custom_content_path,
                        gpg_key_url:     repository.yum_gpg_key_url,
                        os_versions:     root.os_versions&.join(','),
                        metadata_expire: root.metadata_expire)
          end
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
