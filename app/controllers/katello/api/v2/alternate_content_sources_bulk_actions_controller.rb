module Katello
  class Api::V2::AlternateContentSourcesBulkActionsController < Api::V2::ApiController
    before_action :find_alternate_content_sources, except: [:refresh_all_alternate_content_sources]

    api :PUT, '/alternate_content_sources/bulk/destroy', N_('Destroy one or more alternate content sources')
    param :ids, Array, desc: N_('List of alternate content source IDs'), required: true
    def destroy_alternate_content_sources
      deletable_alternate_content_sources = @alternate_content_sources.deletable

      if deletable_alternate_content_sources.empty?
        msg = _("Unable to delete any alternate content source. You either do not have the permission to"\
          " delete, or none of the alternate content sources exist.")
        fail HttpErrors::UnprocessableEntity, msg
      end
      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::AlternateContentSource::Destroy,
                        deletable_alternate_content_sources)
      respond_for_async :resource => task
    end

    api :POST, '/alternate_content_sources/bulk/refresh', N_('Refresh alternate content sources')
    param :ids, Array, desc: N_('List of alternate content source IDs'), required: true
    def refresh_alternate_content_sources
      refreshable_alternate_content_sources = @alternate_content_sources.editable
      if refreshable_alternate_content_sources.empty?
        msg = _("Unable to refresh any alternate content source. You either do not have the permission to"\
                " refresh, or none of the alternate content sources exist.")
        fail HttpErrors::UnprocessableEntity, msg
      else
        task = async_task(::Actions::BulkAction,
                          ::Actions::Katello::AlternateContentSource::Refresh,
                          refreshable_alternate_content_sources)
        respond_for_async resource: task
      end
    end

    api :POST, '/alternate_content_sources/bulk/refresh_all', N_("Refresh all alternate content sources")
    def refresh_all_alternate_content_sources
      refreshable_alternate_content_sources = AlternateContentSource.editable
      if refreshable_alternate_content_sources.empty?
        msg = _("Unable to refresh any alternate content source. You either do"\
          " not have the permission to refresh, or no alternate content sources exist.")
        fail HttpErrors::UnprocessableEntity, msg
      else
        task = async_task(::Actions::BulkAction,
                          ::Actions::Katello::AlternateContentSource::Refresh,
                          refreshable_alternate_content_sources)
        respond_for_async resource: task
      end
    end

    private

    def find_alternate_content_sources
      params.require(:ids)
      @alternate_content_sources = AlternateContentSource.readable.where(id: params[:ids])
    end
  end
end
