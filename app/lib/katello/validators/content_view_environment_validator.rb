module Katello
  module Validators
    class ContentViewEnvironmentValidator < ActiveModel::Validator
      def validate(record)
        #support lifecycle_environment_id for foreman models
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id

        if record.content_view_id
          view = ContentView.where(:id => record.content_view_id).first
          if environment_id
            env = KTEnvironment.where(:id => environment_id).first
            unless view.blank? || env.blank? || view.in_environment?(env)
              record.errors[:base] << _("Content view '%{view}' is not in environment '%{env}'") %
                                        {:view => view.name, :env => env.name}
            end
          end
          if view&.generated_for_repository?
            record.errors[:base] << _("Generated Content views cannot be assigned to Host/Activation Keys")
          end
        end
      end
    end
  end
end
