module Katello
  class Api::V2::DockerTagsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a docker tag"), :resource => "docker_tags")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_repositories, :only => [:auto_complete_name]

    def auto_complete_name
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      tags = Katello::DockerMetaTag.in_repositories(@repositories)
      col = "#{Katello::DockerMetaTag.table_name}.name"
      tags = tags.where("#{col} ILIKE ?", "#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      render :json => tags.pluck(col)
    end

    def index
      if params[:grouped]
        # group docker tags by name, repo, and product
        repos = Repository.readable
        repos = repos.in_organization(@organization) if @organization
        collection = Katello::DockerMetaTag.in_repositories(repos, true)
        respond(:collection => scoped_search(collection, "name", "DESC"))
      else
        super
      end
    end

    api :GET, "/docker_tags/:id/repositories", N_("List of repositories for a docker meta tag")
    param :archived, :bool, :desc => N_("include archived repositories")
    def repositories
      if ::Foreman::Cast.to_bool params[:archived]
        repos = DockerMetaTag.find(params[:id]).repositories
      else
        repos = DockerMetaTag.find(params[:id]).repositories.non_archived
      end
      
      respond_with_template_collection('index', 'repositories', collection: full_result_response(repos))
    end

    private

    def find_repositories
      @repositories = Repository.readable.where(:id => params[:repoids])
    end

    def resource_class
      DockerMetaTag
    end
  end
end
