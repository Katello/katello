module Katello
  class ProductsController < Katello::ApplicationController
    respond_to :html, :js

    before_action :find_product, :only => [:available_repositories, :toggle_repository]
    before_action :find_provider, :only => [:available_repositories, :toggle_repository]
    before_action :find_content, :only => [:toggle_repository]

    include ForemanTasks::Triggers

    def section_id
      'contents'
    end

    def available_repositories
      if @product.custom?
        render_bad_parameters _('Repository sets are not available for custom products.')
      else
        task = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, params[:content_id])

        repos = task.output[:results]
        repos = exclude_rolling_kickstart_repos(repos)
        repos = available_synced_repos(repos, params[:content_id])

        locals = {:scan_cdn => task, :repos => repos, :error_message => nil}
        locals[:error_message => task_error(task)] if task.result == 'warning'
        render :partial => 'katello/providers/redhat/repos', :locals => locals
      end
    end

    def toggle_repository
      action_class = if params[:repo] == '1'
                       ::Actions::Katello::RepositorySet::EnableRepository
                     else
                       ::Actions::Katello::RepositorySet::DisableRepository
                     end
      task = sync_task(action_class, @product, @content, params[:substitutions], :registry_name => params[:registry_name])
      render :json => { :task_id => task.id }
    rescue => e
      render :partial => 'katello/providers/redhat/enable_errors', :locals => { :error_message => e.message}, :status => 500
    end

    private

    def find_provider
      @provider = @product.provider if @product #don't trust the provider_id coming in if we don't need it
      @provider ||= Provider.find(params[:provider_id])
    end

    def find_product
      @product = Product.find(params[:id])
    end

    def find_content
      if (product_content = @product.product_content_by_id(params[:content_id]))
        @content = product_content.content
      else
        fail HttpErrors::NotFound, _("Couldn't find content '%s'") % params[:content_id]
      end
    end

    def task_error(task)
      task.failed_steps.first.action(task.execution_plan).steps.map { |s| s.try(:error).try(:message) }.reject(&:blank?).join(', ')
    end

    def exclude_rolling_kickstart_repos(repos)
      repos.select do |repo|
        if repo[:path].include?('kickstart')
          variants = ['Server', 'Client', 'ComputeNode', 'Workstation']
          has_variant = variants.any? { |v| repo[:substitutions][:releasever].try(:include?, v) }
          has_variant ? repo[:enabled] : true
        else
          true
        end
      end
    end

    def available_synced_repos(repos, content_id)
      @product.repositories.in_default_view.where(:content_id => content_id).find_each do |product_repo|
        found = repos.detect do |repo|
          product_repo.substitutions.compact == repo['substitutions'].compact
        end
        unless found
          repos << {
            :repo_name => product_repo.name,
            :path => product_repo.url,
            :pulp_id => product_repo.pulp_id,
            :content_id => product_repo.content_id,
            :substitutions => product_repo.substitutions,
            :enabled => true,
            :promoted => product_repo.promoted?,
            :registry_name => product_repo.docker_upstream_name
          }
        end
      end
      repos
    end
  end
end
