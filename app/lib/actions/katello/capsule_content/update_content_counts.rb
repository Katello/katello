module Actions
  module Katello
    module CapsuleContent
      class UpdateContentCounts < Actions::EntryAction
        def plan(smart_proxy, options = {})
          input[:options] = options
          plan_self(:smart_proxy_id => smart_proxy.id, environment_id: options[:environment_id], content_view_id: options[:content_view_id], repository_id: options[:repository_id])
        end

        def humanized_name
          _("Update Content Counts")
        end

        def run
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          env = find_env(input[:environment_id])
          content_view = find_content_view(input[:content_view_id])
          repository = find_repository(input[:repository_id])
          smart_proxy.update_content_counts! env, content_view, repository
        end

        def find_env(environment_id)
          ::Katello::KTEnvironment.find(environment_id) if environment_id
        end

        def find_content_view(content_view_id)
          ::Katello::ContentView.find(content_view_id) if content_view_id
        end

        def find_repository(repository_id)
          ::Katello::Repository.find(repository_id) if repository_id
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
