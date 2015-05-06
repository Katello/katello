module Katello
  class ContentViewsController < Katello::ApplicationController
    def auto_complete
      query = "name_autocomplete:#{params[:term]}"
      org = current_organization

      readable_ids = ContentView.readable.where(:default => false).pluck(:id)
      readable_ids << current_organization.default_content_view.id if Product.readable?

      content_views = ContentView.search do
        query do
          string query
        end
        filter :term, :organization_id => org.id
        filter :terms, :id => readable_ids
      end

      render :json => content_views.collect { |s| {:label => s.name, :value => s.name, :id => s.id} }
    rescue Tire::Search::SearchRequestFailed
      render :json => Support.array_with_total
    end
  end
end
