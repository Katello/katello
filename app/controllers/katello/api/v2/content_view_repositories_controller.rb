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
      kr = Katello::Repository.table_name
      krr = Katello::RootRepository.table_name
      kcvr = Katello::ContentViewRepository.table_name
      join_query = <<-SQL
        LEFT OUTER JOIN #{kcvr}
        ON #{kr}.id = #{kcvr}.repository_id
        AND #{kcvr}.content_view_id = #{@content_view.id}
      SQL
      order_query = <<-SQL
        CAST (#{kcvr}.repository_id as BOOLEAN) ASC, #{krr}.name
      SQL

      query = Katello::Repository.readable.in_default_view.in_organization(@organization)
      query = query.with_type(params[:content_type]) if params[:content_type]
      # Use custom sort to perform the join and order since we need to order by specific content_view
      # and the ORDER BY query needs access to the katello_content_view_repositories table
      custom_sort = ->(sort_query) { sort_query.joins(:root).joins(join_query).order(Arel.sql(order_query)) }
      options = { resource_class: Katello::Repository, custom_sort: custom_sort }
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
