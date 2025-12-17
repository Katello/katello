module Katello
  class Api::V2::SyncStatusController < Api::V2::ApiController
    include SyncManagementHelper::RepoMethods

    before_action :find_optional_organization, :only => [:index, :poll, :sync]
    before_action :find_repository, :only => [:destroy]

    api :GET, "/sync_status", N_("Get sync status for all repositories in an organization")
    param :organization_id, :number, :desc => N_("ID of an organization"), :required => false
    def index
      org = @organization || current_organization_object
      fail HttpErrors::NotFound, _("Organization required") if org.nil?

      products = org.library.products.readable
      redhat_products, custom_products = products.partition(&:redhat?)
      redhat_products.sort_by! { |p| p.name.downcase }
      custom_products.sort_by! { |p| p.name.downcase }

      sorted_products = redhat_products + custom_products

      @product_tree = collect_repos(sorted_products, org.library, false)

      # Filter out products and intermediate nodes with no repositories
      @product_tree = filter_empty_nodes(@product_tree)

      @repo_statuses = collect_all_repo_statuses(sorted_products, org.library)

      respond_for_index(:collection => {:products => @product_tree, :repo_statuses => @repo_statuses})
    end

    api :GET, "/sync_status/poll", N_("Poll sync status for specified repositories")
    param :repository_ids, Array, :desc => N_("List of repository IDs to poll"), :required => true
    param :organization_id, :number, :desc => N_("ID of an organization"), :required => false
    def poll
      repos = Repository.where(:id => params[:repository_ids]).readable
      statuses = repos.map { |repo| format_sync_progress(repo) }

      respond_for_index(:collection => statuses)
    end

    api :POST, "/sync_status/sync", N_("Synchronize repositories")
    param :repository_ids, Array, :desc => N_("List of repository IDs to sync"), :required => true
    param :organization_id, :number, :desc => N_("ID of an organization"), :required => false
    def sync
      collected = []
      repos = Repository.where(:id => params[:repository_ids]).syncable

      repos.each do |repo|
        if latest_task(repo).try(:state) != 'running'
          ForemanTasks.async_task(::Actions::Katello::Repository::Sync, repo)
        end
        collected << format_sync_progress(repo)
      end

      respond_for_index(:collection => collected)
    end

    api :DELETE, "/sync_status/:id", N_("Cancel repository synchronization")
    param :id, :number, :desc => N_("Repository ID"), :required => true
    def destroy
      @repository.cancel_dynflow_sync
      render :json => {:message => _("Sync canceled")}
    end

    private

    def find_repository
      @repository = Repository.where(:id => params[:id]).syncable.first
      fail HttpErrors::NotFound, _("Repository not found or not syncable") if @repository.nil?
    end

    def format_sync_progress(repo)
      ::Katello::SyncStatusPresenter.new(repo, latest_task(repo)).sync_progress
    end

    def latest_task(repo)
      repo.latest_dynflow_sync
    end

    def collect_all_repo_statuses(products, env)
      statuses = {}
      products.each do |product|
        product.repos(env).each do |repo|
          statuses[repo.id] = format_sync_progress(repo)
        end
      end
      statuses
    end
  end
end
