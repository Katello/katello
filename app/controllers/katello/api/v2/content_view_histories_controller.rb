module Katello
  class Api::V2::ContentViewHistoriesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_content_view

    api :GET, "/content_views/:id/history", N_("Show a content view's history")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def index
      respond_for_index :collection => scoped_search(index_relation.uniq, :katello_content_view_version_id, :asc, :resource_class => ContentViewHistory)
    end

    def index_relation
      ContentViewHistory.joins(:content_view_version).where("#{ContentViewVersion.table_name}.content_view_id" => @view.id)
    end

    private

    def find_content_view
      @view = ContentView.find(params[:content_view_id]) if params[:content_view_id]
    end
  end
end
