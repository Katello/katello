module Katello
  class Api::V2::ContentExportIncrementalsController < Api::V2::ExportsController
    before_action :find_exportable_organization, :only => [:library]
    before_action :find_exportable_content_view_version, :only => [:version]
    before_action :find_exportable_repository, :only => [:repository]
    before_action :find_library_export_view, :only => [:library]
    before_action :find_repository_export_view, :only => [:repository]
    before_action :find_history, :only => [:version, :library, :repository]

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
      @view = ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(destination_server: params[:destination_server],
                                                                organization: @organization,
                                                                format: find_export_format,
                                                                create_by_default: false)
      if @view.blank?
        msg = _("Unable to incrementally export. Do a Full Export on the library content "\
                "before updating from the latest increment.")
        fail HttpErrors::BadRequest, msg
      end
    end

    def find_repository_export_view
      @view = ::Katello::Pulp3::ContentViewVersion::Export.find_repository_export_view(
                                                                repository: @repository,
                                                                create_by_default: false,
                                                                format: find_export_format)
      if @view.blank?
        msg = _("Unable to incrementally export. Do a Full Export on the repository content.")
        fail HttpErrors::BadRequest, msg
      end
    end
  end
end
