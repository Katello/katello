module Katello
  class Api::V2::DockerTagsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a docker tag"), :resource => "docker_tags")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_repositories, :only => [:auto_complete_name]
    before_action :find_optional_organization, :only => [:repositories, :index, :show, :auto_complete_search]

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
    def repositories
      tag = DockerMetaTag.find(params[:id])

      if tag.repositories.size > 1 #pulp3
        repos = tag.repositories.non_archived
        repos = repos.in_organization(@organization) if @organization
      else
        repos = []
        tag.related_tags.each do |related|
          repos << related.repositories.non_archived
        end
        repos.flatten!
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
