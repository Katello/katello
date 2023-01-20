module Katello
  class Api::V2::ContentExportIncrementalsController < Api::V2::ApiController
    include Katello::Concerns::Api::V2::ExportsController
    before_action :find_exportable_organization, :only => [:library]
    before_action :find_exportable_content_view_version, :only => [:version]
    before_action :find_exportable_repository, :only => [:repository]
    before_action :find_library_export_view, :only => [:library]
    before_action :find_repository_export_view, :only => [:repository]
    before_action :find_history, :only => [:version, :library, :repository]

    api :POST, "/content_export_incrementals/version", N_("Performs an incremental-export of a content view version.")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_gb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in gigabytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                                 "If not provided the most recent export history will be used."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this version"\
                                                         " are unexportable. False by default."), :required => false
    param :format, ::Katello::Pulp3::ContentViewVersion::Export::FORMATS,
                   :desc => N_("Export formats. Choose syncable if content is to be imported via repository sync. "\
                               "Choose importable if content is to be imported via hammer content-import.
                                Defaults to importable."),
                   :required => false
    def version
      export_content_view_version
    end

    api :POST, "/content_export_incrementals/library", N_("Performs an incremental-export of the repositories in library.")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :destination_server, String, :desc => N_("Destination Server name"), :required => false
    param :chunk_size_gb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in gigabytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                                 "If not provided the most recent export history will be used."), :required => false
    param :fail_on_missing_content, :bool, :desc => N_("Fails if any of the repositories belonging to this organization"\
                                                         " are unexportable. False by default."), :required => false
    param :format, ::Katello::Pulp3::ContentViewVersion::Export::FORMATS,
                   :desc => N_("Export formats. Choose syncable if content is to be imported via repository sync. "\
                               "Choose importable if content is to be imported via hammer content-import.
                                Defaults to importable."),
                   :required => false
    def library
      export_library
    end

    api :POST, "/content_export_incrementals/repository", N_("Performs a incremental-export of the repository in library.")
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    param :chunk_size_gb, :number, :desc => N_("Split the exported content into archives "\
                                               "no greater than the specified size in gigabytes."), :required => false
    param :from_history_id, :number, :desc => N_("Export history identifier used for incremental export. "\
                                                 "If not provided the most recent export history will be used."), :required => false
    param :format, ::Katello::Pulp3::ContentViewVersion::Export::FORMATS,
                   :desc => N_("Export formats. Choose syncable if content is to be imported via repository sync. "\
                               "Choose importable if content is to be imported via hammer content-import.
                                Defaults to importable."),
                   :required => false
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
