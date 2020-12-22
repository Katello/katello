module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        include Actions::Katello::PulpSelector
        include ActionView::Helpers::TextHelper

        # rubocop:disable Metrics/MethodLength
        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance
          action_params = {
            repository_id: root.library_instance.id,
            cp_consumers: []
          }

          repo_params[:url] = nil if repo_params[:url] == ''
          update_cv_cert_protected = repo_params.key?(:unprotected) && (repo_params[:unprotected] != repository.unprotected)

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
                        :arches => root.format_arches,
                        :os_versions => root.os_versions&.join(',')
                      )

            content.update!(name: root.name,
                                       content_url: root.custom_content_path,
                                       content_type: repository.content_type,
                                       label: content.label,
                                       gpg_url: repository.yum_gpg_key_url)

            if root.previous_changes.key?('os_versions')
              # If Restrict to OS Version is changing _from_ or _to_ 'rhel-6'...
              if root.previous_changes['os_versions'].any? { |ch| ch.include?('rhel-6') }
                # ...force regeneration of entitlement certs on RHEL 6.8 and older (see run method)
                Rails.logger.info("Looking for RHEL 6.8 and older clients")
                cp_consumers = ::Katello::Host::ContentFacet
                  .joins(host: :operatingsystem)
                  .where("operatingsystems.major = '6' AND operatingsystems.minor < '9' AND operatingsystems.name = 'RedHat'")
                  .map(&:uuid)
                action_params[:cp_consumers] = cp_consumers
                action_params[:org_label] = root.organization.label
              end
            end

          end
          if root.pulp_update_needed?
            sequence do
              plan_pulp_action([::Actions::Pulp::Orchestration::Repository::Refresh,
                                ::Actions::Pulp3::Orchestration::Repository::Update],
                               repository,
                               SmartProxy.pulp_primary)
              if update_cv_cert_protected
                plan_optional_pulp_action([::Actions::Pulp3::Orchestration::Repository::TriggerUpdateRepoCertGuard], repository, ::SmartProxy.pulp_primary)
              end
            end
          end
          plan_self(action_params)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          repository.clear_smart_proxy_sync_histories
          if input[:cp_consumers].present?
            ForemanTasks.async_task(
              ::Actions::Candlepin::Consumer::RegenerateEntitlementCertificates,
              input[:cp_consumers],
              input[:org_label]
            )
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
