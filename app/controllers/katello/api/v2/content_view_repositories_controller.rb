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
    param :only, ["available", "added"], desc: N_("only show a subset of results, either 'available' or 'added'")
    def show_all
      query = Repository.readable
      ids = []
      ids += @organization.default_content_view.versions.first.repositories.pluck(:id) unless params[:only] == 'added'
      added_ids = @content_view.repositories.pluck(:id)
      if params[:only] == 'available'
        ids -= added_ids
      else
        ids += added_ids
      end
      query = query.where(id: ids.uniq)
      sorted_ids = query.sort_by { |repo| repo.in_content_view?(@content_view) ? 0 : 1 }.pluck(:id)
      sorted_query = Katello::Repository.where(id: sorted_ids)

      # Make sure the added content views are returned first
      options = { resource_class: Katello::Repository,
                  deterministic_order: "array_position(array[#{sorted_ids.join(',')}], #{Katello::Repository.table_name}.id)" }
      repos = scoped_search(sorted_query, nil, nil, options)

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
