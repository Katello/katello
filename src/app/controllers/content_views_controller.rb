class ContentViewsController < ApplicationController
  before_filter :authorize

  def rules
    auto_complete_test = lambda { ContentView.any_readable?(current_organization) }
    {
      :auto_complete => auto_complete_test
    }
  end

  def auto_complete
    query = "name_autocomplete:#{params[:term]}"
    org = current_organization
    content_views = ContentView.search do
      query do
        string query
      end
      filter :term, {:organization_id => org.id}
    end
    render :json=>content_views.collect{|s| {:label=>s.name, :value=>s.name, :id=>s.id}}
  rescue Tire::Search::SearchRequestFailed => e
    render :json=>Support.array_with_total
  end
end
