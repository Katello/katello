module Katello
  class Api::V2::DistributionsController < Api::V2::ApiController
    before_filter :find_repository
    before_filter :find_distribution, :only => [:show]
    before_filter :deprecated

    api :GET, "/repositories/:repository_id/distributions", "List distributions", :deprecated => true
    param :repository_id, :identifier, :desc => "Repository id to list packages for"
    param_group :search, Api::V2::ApiController
    def index
      options = {
        :filters => [{:terms => {:repoids => [@repo.pulp_id]}}]
      }
      collection = item_search(Distribution, params, options)

      respond(:collection => collection)
    end

    api :GET, "/repositories/:repository_id/distributions/:id", "Show a distribution", :deprecated => true
    param :repository_id, :number, :desc => "repository numeric id"
    param :id, String, :desc => "distribution id"
    def show
      respond :resource => @distribution
    end

    private

    def deprecated
      ::Foreman::Deprecation.api_deprecation_warning("it will be changed in Katello 2.4, where Distribution information will be included in /repositories/:repository_id")
    end

    def find_repository
      @repo = Repository.find(params[:repository_id])
      fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
    end

    def find_distribution
      @distribution = Distribution.find(params[:id])
      fail HttpErrors::NotFound, _("Distribution with id '%s' not found") % params[:id] if @distribution.nil?
      fail HttpErrors::NotFound, _("Distribution '%s' not found within the repository") % params[:id] unless @distribution.repoids.include? @repo.pulp_id
    end
  end
end
