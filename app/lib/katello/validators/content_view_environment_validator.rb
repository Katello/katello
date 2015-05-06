module Katello
  module Validators
    class ContentViewEnvironmentValidator < ActiveModel::Validator
      def validate(record)
        #support lifecycle_environment_id for foreman models
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id

        if record.content_view_id && environment_id
          view = ContentView.find(record.content_view_id)
          env = KTEnvironment.find(environment_id)
          unless view.in_environment?(env)
            record.errors[:base] << _("Content view '%{view}' is not in environment '%{env}'") %
                                      {:view => view.name, :env => env.name}
          end
        end
      end
    end
  end
end
