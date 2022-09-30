module Actions
  module Katello
    module ContentView
      class Promote < Actions::EntryAction
        extend ApipieDSL::Class
        include ::Actions::ObservableAction

        def plan(version, environments, is_force = false, description = nil, incremental_update = false)
          action_subject(version.content_view)
          version.check_ready_to_promote!(environments)
          ::Katello::Util::CandlepinRepositoryChecker.check_repositories_for_promote!(version)

          fail ::Katello::HttpErrors::BadRequest, _("Cannot promote environment out of sequence. Use force to bypass restriction.") if !is_force && !version.promotable?(environments)

          # Pass the environments as input in order to make them accessible to UI alerts
          plan_self(environments: environments.map(&:name))
          environments.each do |environment|
            sequence do
              plan_action(Katello::ContentViewVersion::BeforePromoteHook, :id => version.id)
              plan_action(ContentView::PromoteToEnvironment, version, environment, description, incremental_update)
              plan_action(Katello::ContentViewVersion::AfterPromoteHook, :id => version.id)
            end
          end
        end

        def environments
          input['environments']
        end

        apipie :class, "A class representing #{self} object" do
          desc 'This object is available as **@object** variable in
                webhook templates when a corresponding event occures.
                The following properties can be used to retrieve the needed information.'
          name "#{class_scope}"
          refs "#{class_scope}"
          sections only: %w[all webhooks]
          property :task, object_of: 'Task', desc: 'Returns the task to which this action belongs'
          property :environments, array_of: String, desc: 'Returns the list of environments the content view was promoted to'
        end
        include Actions::Katello::JailConcern::Organization
        include Actions::Katello::JailConcern::ContentView
        class Jail < ::Actions::ObservableAction::Jail
          allow :organization_id, :organization_name, :organization_label,
                :content_view_id, :content_view_name, :content_view_label,
                :environments
        end
      end
    end
  end
end
