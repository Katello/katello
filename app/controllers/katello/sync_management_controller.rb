module Katello
  class SyncManagementController < Katello::ApplicationController
    include TranslationHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
    include SyncManagementHelper::RepoMethods
    helper Rails.application.routes.url_helpers
    helper ReactjsHelper
    respond_to :html, :json

    def section_id
      'contents'
    end

    def title
      _('Sync Status')
    end

    def index
      org = current_organization_object
      @products = org.library.products.readable
      redhat_products, custom_products = @products.partition(&:redhat?)
      redhat_products.sort_by { |p| p.name.downcase }
      custom_products.sort_by { |p| p.name.downcase }

      @products = redhat_products + custom_products
      @product_size = {}
      @repo_status = {}
      @product_map = collect_repos(@products, org.library, false)

      @products.each { |product| get_product_info(product) }
    end

    def sync
      begin
        tasks = sync_repos(params[:repoids]) || []
        render json: tasks.as_json
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def sync_status
      repos = Repository.where(:id => params[:repoids]).readable
      statuses = repos.map { |repo| format_sync_progress(repo) }
      render :json => statuses.flatten.to_json
    end

    def destroy
      repo = Repository.where(:id => params[:id]).syncable.first
      repo&.cancel_dynflow_sync
      render :plain => ""
    end

    private

    def format_sync_progress(repo)
      ::Katello::SyncStatusPresenter.new(repo, latest_task(repo)).sync_progress
    end

    def latest_task(repo)
      repo.latest_dynflow_sync
    end

    # loop through checkbox list of products and sync
    def sync_repos(repo_ids)
      collected = []
      repos = Repository.where(:id => repo_ids).syncable
      repos.each do |repo|
        if latest_task(repo).try(:state) != 'running'
          ForemanTasks.async_task(::Actions::Katello::Repository::Sync, repo)
        end
        collected << format_sync_progress(repo)
      end
      collected
    end

    def get_product_info(product)
      product.repos(product.organization.library).each do |repo|
        @repo_status[repo.id] = format_sync_progress(repo)
      end
    end
  end
end
