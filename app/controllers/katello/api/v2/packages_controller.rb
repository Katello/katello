module Katello
  class Api::V2::PackagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package"), :resource => "packages")
    include Katello::Concerns::Api::V2::RepositoryContentController
    include Katello::Concerns::Api::V2::RepositoryDbContentController

    before_filter :find_repositories, :only => :auto_complete_name

    api :GET, "/packages", N_("List packages")
    api :GET, "/repositories/:repository_id/packages", N_("List packages")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    def auto_complete_name
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      rpms = Rpm.in_repositories(@repositories)
      col = "#{Rpm.table_name}.name"
      rpms = rpms.where("#{Rpm.table_name}.name ILIKE ?", "#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      render :json => rpms.pluck(col)
    end

    def find_repositories
      @repositories = Repository.readable.where(:id => params[:repoids])
    end

    def resource_class
      Katello::Rpm
    end

    def default_sort
      lambda { |query| query.default_sort }
    end
  end
end
