module Katello
  module Util
    class FakeActivationKey < ApplicationRecord
      self.table_name = 'katello_activation_keys'
    end

    class CVEAKMigrator # used in db/migrate/20240730163043_add_content_view_environment_activation_key.rb
      def execute!
        aks_with_no_cve = []
        aks_with_missing_cve = []

        FakeActivationKey.all.each do |ak|
          next if ak.content_view_id.blank? && ak.environment_id.blank?
          if ::Katello::ContentView.exists?(id: ak.content_view_id) && ::Katello::KTEnvironment.exists?(ak.environment_id)
            cve = ::Katello::ContentViewEnvironment.find_by(content_view_id: ak.content_view_id, environment_id: ak.environment_id)
            if cve.blank?
              aks_with_no_cve << ak
            end
          else
            aks_with_missing_cve << ak
          end
        end

        if aks_with_missing_cve.present? || aks_with_no_cve.present?
          Rails.logger.warn "Found #{aks_with_no_cve.count} activation keys whose combination of content view and lifecycle environment does not have a corresponding ContentViewEnvironment"
          Rails.logger.warn "Found #{aks_with_missing_cve.count} activation keys which are missing either content_view_id or lifecycle_environment_id"
          Rails.logger.info "You may want to change the content view / lifecycle environment for these activation keys manually."
        end
        (aks_with_no_cve + aks_with_missing_cve).each do |ak|
          default_content_view = ak.organization.default_content_view
          library = ak.organization.library
          Rails.logger.info "Updating activation key #{ak.name} with default content_view_id and lifecycle_environment_id"
          ak&.update_columns(content_view_id: default_content_view&.id, environment_id: library&.id)
        end
      end
    end
  end
end
