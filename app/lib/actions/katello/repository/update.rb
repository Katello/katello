module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        include Actions::Katello::PulpSelector

        # rubocop:disable Metrics/MethodLength
        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance

          repo_params[:url] = nil if repo_params[:url] == ''
          update_cv_cert_protected = (repo_params[:unprotected] != repository.unprotected)

          root.update!(repo_params)

          if root.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND
            ::Foreman::Deprecation.api_deprecation_warning("Background download_policy will be removed in Katello 4.0.  Any background repositories will be converted to Immediate")
          end

          if root['content_type'] == 'puppet' || root['content_type'] == 'ostree'
            ::Foreman::Deprecation.api_deprecation_warning("Repository types of 'Puppet' and 'OSTree' will no longer be supported in Katello 4.0.")
          end

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
                        :arches => root.format_arches)

            content.update!(name: root.name,
                                       content_url: root.custom_content_path,
                                       content_type: repository.content_type,
                                       label: content.label,
                                       gpg_url: repository.yum_gpg_key_url)
          end
          if root.pulp_update_needed?
            plan_pulp_action([::Actions::Pulp::Orchestration::Repository::Refresh,
                              ::Actions::Pulp3::Orchestration::Repository::Update],
                             repository,
                             SmartProxy.pulp_master)
            plan_self(:repository_id => root.library_instance.id, :update_cv_cert_protected => update_cv_cert_protected)
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          output[:repository_id] = input[:repository_id]
          output[:update_cv_cert_protected] = input[:update_cv_cert_protected]
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end

        def finalize
          repository = ::Katello::Repository.find(output[:repository_id])
          if output[:update_cv_cert_protected]
            ForemanTasks.async_task(::Actions::Katello::Repository::UpdateCVRepoCertGuard, repository, SmartProxy.pulp_master)
          end
        end

        private

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end
      end
    end
  end
end
