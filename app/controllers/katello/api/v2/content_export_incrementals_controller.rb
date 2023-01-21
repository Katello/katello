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
    export_version_description(incremental: true)
    def version
      export_content_view_version
    end

    api :POST, "/content_export_incrementals/library", N_("Performs an incremental-export of the repositories in library.")
    export_library_description(incremental: true)
    def library
      export_library
    end

    api :POST, "/content_export_incrementals/repository", N_("Performs a incremental-export of the repository in library.")
    export_repository_description(incremental: true)
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
