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
          create_acs = create_acs?(repository.url, repo_params[:url])
          delete_acs = delete_acs?(repository.url, repo_params[:url])

          # Keep the old URL for RPM vs ULN remote cleanup
          old_url = root.url
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
              plan_action(::Actions::Pulp3::Orchestration::Repository::Update,
                               repository,
                               SmartProxy.pulp_primary)
              plan_self(:repository_id => root.library_instance.id)
              if update_cv_cert_protected
                plan_optional_pulp_action([::Actions::Pulp3::Orchestration::Repository::TriggerUpdateRepoCertGuard], repository, ::SmartProxy.pulp_primary)
              end

              handle_alternate_content_sources(repository, create_acs, delete_acs, old_url)
            end
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          repository.clear_smart_proxy_sync_histories
        end

        private

        def handle_alternate_content_sources(repository, create_acs, delete_acs, old_url)
          if create_acs
            repository.product.alternate_content_sources.each do |acs|
              acs.smart_proxies.each do |smart_proxy|
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repository.id)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
              end
            end
          elsif delete_acs
            repository.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs, old_url: old_url)
            end
          else
            repository.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)
            end
          end
        end

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end

        def create_acs?(old_url, new_url)
          old_url.nil? && new_url.present?
        end

        def delete_acs?(old_url, new_url)
          old_url.present? && new_url.nil?
        end
      end
    end
  end
end
