module Katello
  class ProductsController < Katello::ApplicationController
    respond_to :html, :js

    before_filter :find_product, :only => [:available_repositories, :toggle_repository]
    before_filter :find_provider, :only => [:available_repositories, :toggle_repository]
    before_filter :find_content, :only => [:toggle_repository]

    include ForemanTasks::Triggers

    def section_id
      'contents'
    end

    def available_repositories
      if @product.custom?
        render_bad_parameters _('Repository sets are not available for custom products.')
      else
        task = sync_task(::Actions::Katello::RepositorySet::ScanCdn, @product, params[:content_id])
        if task.result == 'warning'
          render :partial => 'katello/providers/redhat/errors', :locals => { :error_message => task_error(task), :task => task}
        else
          repos = task.output[:results]

          repos = repos.select do |repo|
            if repo[:path].include?('kickstart')
              repo[:substitutions][:releasever].include?('Server') ? repo[:enabled] : true
            else
              true
            end
          end

          render :partial => 'katello/providers/redhat/repos', :locals => {:scan_cdn => task, :repos => repos}
        end
      end
    end

    def toggle_repository
      action_class = if params[:repo] == '1'
                       ::Actions::Katello::RepositorySet::EnableRepository
                     else
                       ::Actions::Katello::RepositorySet::DisableRepository
                     end
      task = sync_task(action_class, @product, @content, substitutions)
      render :json => { :task_id => task.id }
    rescue => e
      render :partial => 'katello/providers/redhat/enable_errors', :locals => { :error_message => e.message}, :status => 500
    end

    #used by content search
    def auto_complete
      products = Product.readable.enabled.where(:organization_id => current_organization).
          where("#{Product.table_name}.name ILIKE ?", "#{params[:term]}%")
      render :json => products.collect { |s| {:label => s.name, :value => s.name, :id => s.id} }
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
      if product_content = @product.product_content_by_id(params[:content_id])
        @content = product_content.content
      else
        fail HttpErrors::NotFound, _("Couldn't find content '%s'") % params[:content_id]
      end
    end

    def substitutions
      params.slice(:basearch, :releasever, :registry_name)
    end

    def task_error(task)
      task.failed_steps.first.action(task.execution_plan).steps.map { |s| s.try(:error).try(:message) }.reject(&:blank?).join(', ')
    end
  end
end
