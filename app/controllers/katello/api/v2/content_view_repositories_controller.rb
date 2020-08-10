module Katello
  class Api::V2::ContentViewRepositoriesController < Api::V2::ApiController
    # There are other Content View Repository related endpoints that are in RepositoriesController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_content_view
    before_action :find_organization_from_cv

    # content_views/:id/repositories/show_all
    # Shows all repositories, added and available to add, for a content view
    # Undocumented endpoint since the functionality exists in separate calls already.
    # This was created for ease of pagination and search for the UI
    param :id, :number, desc: N_("Content View id"), required: true
    def show_all
      query = Katello::Repository.all_for_content_view(@content_view.id);
      options = { resource_class: Katello::Repository, fixed_query: true }
      repos = scoped_search(query, nil, nil, options)

      respond_for_index(:collection => repos)
    end

    private

    def find_content_view
      @content_view = ContentView.find(params[:content_view_id])
    end

    def find_organization_from_cv
      @organization = @content_view.organization
    end
  end
end
