module Katello
  module Validators
    # used by activation key and content facet
    class ContentViewEnvironmentValidator < ActiveModel::Validator
      def validate(record)
        #support lifecycle_environment_id for foreman models
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id
        if record.content_view_id
          view = ContentView.where(:id => record.content_view_id).first
          if environment_id
            env = KTEnvironment.where(:id => environment_id).first
            unless view.blank? || env.blank? || view.in_environment?(env)
              record.errors.add(:base, _("Content view '%{view}' is not in environment '%{env}'") %
                                        {:view => view.name, :env => env.name})
            end
          end
          if view&.generated_for_repository?
            record.errors.add(:base, _("Generated content views cannot be assigned to hosts or activation keys"))
          end
        end
      end
    end
  end
end
