module Actions
  module Katello
    module CapsuleContent
      class VerifyChecksum < ::Actions::EntryAction
        def humanized_name
          _("Verify checksum for content on smart proxy")
        end

        def plan(smart_proxy, options = {})
          input[:options] = options
          action_subject(smart_proxy)
          fail _("Action not allowed for the default smart proxy.") if smart_proxy.pulp_primary?
          subjects = subjects(options)
          repair_options = options.merge(subjects)
          environment = repair_options[:environment]
          content_view = repair_options[:content_view]
          check_cv_capsule_environments!(smart_proxy, content_view, environment)
          repository = repair_options[:repository]
          repos = repos_to_repair(smart_proxy, environment, content_view, repository)
          repos.in_groups_of(Setting[:foreman_proxy_content_batch_size], false) do |repo_batch|
            concurrence do
              repo_batch.each do |repo|
                if smart_proxy.pulp3_support?(repo)
                  plan_action(Actions::Pulp3::CapsuleContent::VerifyChecksum,
                              repo,
                              smart_proxy)
                end
              end
            end
          end
        end

        def repos_to_repair(smart_proxy, environment, content_view, repository)
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_helper.lifecycle_environment_check(environment, repository)
          if repository
            [repository]
          else
            repositories = smart_proxy_helper.repositories_available_to_capsule(environment, content_view).by_rpm_count
            repositories
          end
        end

        def check_cv_capsule_environments!(smart_proxy, content_view, environment)
          cv_environments = content_view&.versions&.collect(&:environments)&.flatten
          if cv_environments.present?
            if environment.present? && !(cv_environments.pluck(:id).include? environment.id)
              fail _("Content view '%{content_view}' is not attached to the environment.") % {content_view: content_view.name}
            end
            if (smart_proxy.lifecycle_environments.pluck(:id) & cv_environments.pluck(:id)).empty?
              fail _("Content view '%{content_view}' is not attached to this capsule.") % {content_view: content_view.name}
            end
          end
        end

        def subjects(options = {})
          environment_id = options.fetch(:environment_id, nil)
          environment = ::Katello::KTEnvironment.find(environment_id) if environment_id

          repository_id = options.fetch(:repository_id, nil)
          repository = ::Katello::Repository.find(repository_id) if repository_id

          content_view_id = options.fetch(:content_view_id, nil)
          content_view = ::Katello::ContentView.find(content_view_id) if content_view_id

          {content_view: content_view, environment: environment, repository: repository}
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
