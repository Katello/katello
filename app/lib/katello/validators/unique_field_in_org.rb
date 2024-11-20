# For models that belongs_to :environment that wish to check a fields uniqueness across the org
# eg. validates_with Validators::UniqueFieldInOrg, :attributes => :name
module Katello
  module Validators
    class UniqueFieldInOrg < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          others = record.class.where(attribute => value).joins(:environment).where("#{Katello::KTEnvironment.table_name}.organization_id" => record.environment.organization_id)
          others = others.where("#{record.class.table_name}.id != ?", record.id) if record.persisted?
          record.errors.add(attribute, N_("already taken")) if others.any?
        end
      end
    end
  end
end
