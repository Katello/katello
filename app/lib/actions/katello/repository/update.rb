module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        include Actions::Katello::PulpSelector

        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance

          repo_params[:url] = nil if repo_params[:url] == ''
          update_cv_cert_protected = repo_params.key?(:unprotected) && (repo_params[:unprotected] != repository.unprotected)

          root.update!(repo_params)

          if update_content?(repository)
            content = root.content

            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        :owner => repository.organization.label,
                        :content_id => root.content_id,
                        :name => root.name,
                        :content_url => root.custom_content_path,
                        :gpg_key_url => repository.yum_gpg_key_url,
                        :label => content.label,
                        :type => root.content_type,
                        :arches => root.format_arches,
                        :os_versions => root.os_versions&.join(',')
                      )

            content.update!(name: root.name,
                                       content_url: root.custom_content_path,
                                       content_type: repository.content_type,
                                       label: content.label,
                                       gpg_url: repository.yum_gpg_key_url)
          end
          if root.pulp_update_needed?
            sequence do
              plan_pulp_action([::Actions::Pulp::Orchestration::Repository::Refresh,
                                ::Actions::Pulp3::Orchestration::Repository::Update],
                               repository,
                               SmartProxy.pulp_primary)
              plan_self(:repository_id => root.library_instance.id)
              if update_cv_cert_protected
                plan_optional_pulp_action([::Actions::Pulp3::Orchestration::Repository::TriggerUpdateRepoCertGuard], repository, ::SmartProxy.pulp_primary)
              end
            end
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          repository.clear_smart_proxy_sync_histories
        end

        private

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end
      end
    end
  end
end
