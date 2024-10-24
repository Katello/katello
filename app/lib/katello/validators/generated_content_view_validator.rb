module Katello
  module Validators
    class GeneratedContentViewValidator < ActiveModel::Validator
      def validate(record)
        record.content_view_environments.each do |cve|
          if cve.content_view_id
            view = ContentView.where(:id => cve.content_view_id).first
            if view&.generated_for_repository?
              record.errors.add(:base, _("Content view '%{cv_name}' is a generated content view, which cannot be assigned to hosts or activation keys.") % { :cv_name => view.name })
            end
          end
        end
      end
    end
  end
end
