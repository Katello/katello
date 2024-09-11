module Katello
  module Util
    class CvecfMigrator # used in db/migrate/20220929204746_add_content_view_environment_content_facet.rb
      def execute!
        hosts_with_no_cve = []
        hosts_with_missing_cve = []

        ::Host::Managed.all.each do |host|
          next if host.content_facet.blank?
          if ::Katello::ContentView.exists?(id: host.content_facet.content_view_id) && ::Katello::KTEnvironment.exists?(host.content_facet.lifecycle_environment_id)
            cve = ::Katello::ContentViewEnvironment.find_by(content_view_id: host.content_facet.content_view_id, environment_id: host.content_facet.lifecycle_environment_id)
            if cve.blank?
              hosts_with_no_cve << host
            end
          else
            hosts_with_missing_cve << host
          end
        end

        if hosts_with_missing_cve.present? || hosts_with_no_cve.present?
          Rails.logger.warn "Found #{hosts_with_no_cve.count} hosts whose lifecycle environment does not have a corresponding ContentViewEnvironment"
          Rails.logger.warn "Found #{hosts_with_missing_cve.count} hosts whose content facet is missing either content_view_id or lifecycle_environment_id"
          Rails.logger.info "You may want to change the content view / lifecycle environment for these hosts manually."
        end
        (hosts_with_no_cve + hosts_with_missing_cve).each do |host|
          default_content_view = host.organization.default_content_view
          library = host.organization.library
          Rails.logger.info "Updating host #{host.name} with default content_view_id and lifecycle_environment_id"
          host.content_facet&.update_columns(content_view_id: default_content_view&.id, lifecycle_environment_id: library&.id)
        end
      end
    end
  end
end
