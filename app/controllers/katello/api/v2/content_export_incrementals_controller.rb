module Katello
  class Api::V2::ContentExportIncrementalsController < Api::V2::ExportsController
    before_action :find_exportable_content_view_version, :only => [:version]                        # determines @view
    before_action :find_exportable_organization, :only => [:library]                                # determines @organization
    before_action :find_library_export_view, :only => [:library]                                    # determines @view from @organization
    before_action :find_exportable_repository, :only => [:repository]                               # finds @repository
    before_action :find_repository_export_view, :only => [:repository]                              # determines @view from @repository
    before_action :find_incremental_history, :only => [:version, :library, :repository]             # determines @history from @view
    before_action :determine_export_format_from_history, :only => [:version, :library, :repository] # determines @export_format from @history

    def_param_group :incremental do
      param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                         "If not provided the most recent export history will be used."), :required => false
    end

    api :POST, "/content_export_incrementals/version", N_("Performs an incremental-export of a content view version.")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param_group :version_fail_on_missing_content, Api::V2::ExportsController
    param_group :destination_server, Api::V2::ExportsController
    param_group :export, Api::V2::ExportsController
    param_group :incremental
    def version
      export_content_view_version
    end

    api :POST, "/content_export_incrementals/library", N_("Performs an incremental-export of the repositories in library.")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param_group :org_fail_on_missing_content, Api::V2::ExportsController
    param_group :destination_server, Api::V2::ExportsController
    param_group :export, Api::V2::ExportsController
    param_group :incremental
    def library
      export_library
    end

    api :POST, "/content_export_incrementals/repository", N_("Performs a incremental-export of the repository in library.")
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    param_group :export, Api::V2::ExportsController
    param_group :incremental
    def repository
      export_repository
    end

    private

    def find_library_export_view
      if params[:from_history_id].present?
        find_incremental_history_from_id
        @view = @history&.content_view_version&.content_view
      else
        # Determine format for finding existing view
        format = params[:format] || ::Katello::Pulp3::ContentViewVersion::Export::UNDEFINED

        # Try to find existing views based on format
        views = []
        if format != ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
          importable_view = ::Katello::Pulp3::ContentViewVersion::Export.find_export_view(
            destination_server: params[:destination_server],
            organization: @organization,
            name: ::Katello::ContentView::EXPORT_LIBRARY,
            generated_for: :library_export
          )
          views << importable_view if importable_view
        end

        if format != ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE
          syncable_view = ::Katello::Pulp3::ContentViewVersion::Export.find_export_view(
            destination_server: params[:destination_server],
            organization: @organization,
            name: "#{::Katello::ContentView::EXPORT_LIBRARY}-SYNCABLE",
            generated_for: :library_export_syncable
          )
          views << syncable_view if syncable_view
        end

        @view = views.compact.max_by(&:updated_at)
      end
      check_for_blank_view
    end

    def find_repository_export_view
      if params[:from_history_id].present?
        find_incremental_history_from_id
        @view = @history&.content_view_version&.content_view
      else
        # Determine format for finding existing view
        format = params[:format] || ::Katello::Pulp3::ContentViewVersion::Export::UNDEFINED

        # Try to find existing views based on format
        views = []
        if format != ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
          importable_view = ::Katello::Pulp3::ContentViewVersion::Export.find_export_view(
            destination_server: nil,
            organization: @repository.organization,
            name: "Export-#{@repository.label}-#{@repository.library_instance_or_self.id}",
            generated_for: :repository_export
          )
          views << importable_view if importable_view
        end

        if format != ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE
          syncable_view = ::Katello::Pulp3::ContentViewVersion::Export.find_export_view(
            destination_server: nil,
            organization: @repository.organization,
            name: "Export-SYNCABLE-#{@repository.label}-#{@repository.library_instance_or_self.id}",
            generated_for: :repository_export_syncable
          )
          views << syncable_view if syncable_view
        end

        @view = views.compact.max_by(&:updated_at)
      end
      check_for_blank_view
    end

    def check_for_blank_view
      if @view.blank?
        valid_params = ""
        valid_params << " 'from_history_id':#{params[:from_history_id]}" if params[:from_history_id].present?
        valid_params << " 'format':#{params[:format]}" if params[:format].present?
        if valid_params.blank?
          msg = _("Unable to find a base content view to use for incremental export. Please run a complete export instead.")
        else
          msg = _("Unable to find a base content view to use for incremental export using the provided parameters:%{params}") % { params: valid_params }
        end
        fail HttpErrors::BadRequest, msg
      end
    end

    def determine_export_format_from_history
      @export_format = @history.metadata[:format]

      if params[:format].present? && @export_format != params[:format]
        msg = _("The provided incremental export format '%{provided}' must match the previous export's format '%{previous}'. "\
          "Consider using 'from_history_id' to point to a matching export.") % { provided: params[:format], previous: @export_format }
        fail HttpErrors::BadRequest, msg
      end
    end
  end
end
