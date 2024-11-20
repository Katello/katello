module Katello
  module Validators
    # ensures that the Default Organization View content view can only be used with the Library environment
    class ContentViewEnvironmentCoherentDefaultValidator < ActiveModel::Validator
      def validate(record)
        #support lifecycle_environment_id for foreman models
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id
        if record.content_view_id
          view = ContentView.where(:id => record.content_view_id).first
          if environment_id
            env = KTEnvironment.where(:id => environment_id).first
            return if view.blank? || env.blank?
            if view.default? && !env.library?
              record.errors.add(:base, _("Lifecycle environment '%{env}' cannot be used with content view '%{view}'") %
                                        {:view => view.name, :env => env.name})
            end
          end
        end
      end
    end
  end
end
