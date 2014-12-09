#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

    def auto_complete
      query = "name_autocomplete:#{params[:term]}"
      org = current_organization

      readable_ids = []
      readable_ids += Product.readable.pluck(:id) if Product.readable?
      readable_ids += ContentView.readable_products.pluck("#{Katello::Product.table_name}.id")
      readable_ids.uniq

      products = Product.search do
        query do
          string query
        end
        filter :term, :organization_id => org.id
        filter :terms, :id => readable_ids
      end

      render :json => products.collect { |s| {:label => s.name, :value => s.name, :id => s.id} }
    rescue Tire::Search::SearchRequestFailed
      render :json => Util::Support.array_with_total
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
      params.slice(:basearch, :releasever)
    end

    def task_error(task)
      task.failed_steps.first.action(task.execution_plan).steps.map { |s| s.try(:error).try(:message) }.reject(&:blank?).join(', ')
    end
  end
end
