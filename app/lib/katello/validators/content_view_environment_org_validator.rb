module Katello
  module Validators
    class ContentViewEnvironmentOrgValidator < ActiveModel::Validator
      def validate(record)
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id
        view = ContentView.where(:id => record.content_view_id).first
        environment = KTEnvironment.where(:id => environment_id).first
        if view.blank? || environment.blank?
          record.errors.add(:base, _("Content view environments must have both a content view and an environment"))
        end

        unless view&.organization == environment&.organization
          record.errors.add(:base, _("%{view_label} could not be promoted to %{environment_label} because the content view and the environment are not in the same organization!") % {:view_label => view&.label, :environment_label => environment&.label})
        end
      end
    end
  end
end
