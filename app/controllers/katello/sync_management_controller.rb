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

# rubocop:disable ClassVars
module Katello
class SyncManagementController < Katello::ApplicationController
  include TranslationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include SyncManagementHelper::RepoMethods
  respond_to :html, :json

  @@status_values = { :stopped      => _("Syncing Complete."),
                      :error        => _("Sync Incomplete"),
                      :never_synced => _("Never Synced"),
                      :paused       => _("Paused")}.with_indifferent_access

  def section_id
    'contents'
  end

  def title
    _('Sync Status')
  end

  def index
    org = current_organization
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
    tasks = sync_repos(params[:repoids]) || []
    render :json => tasks.as_json
  end

  def sync_status
    repos = Repository.where(:id => params[:repoids]).readable
    statuses = repos.map{ |repo| format_sync_progress(repo) }
    render :json => statuses.flatten.to_json
  end

  def destroy
    repo = Repository.where(:id => params[:id]).syncable.first
    repo.cancel_dynflow_sync if repo
    render :text => ""
  end

  private

  def format_sync_progress(repo)
    task = latest_task(repo)
    if task
      {   :id             => repo.id,
          :product_id     => repo.product.id,
          :progress       => {:progress => task.progress * 100},
          :sync_id        => task.id,
          :state          => format_state(task),
          :raw_state      => raw_state(task),
          :start_time     => format_date(task.started_at),
          :finish_time    => format_date(task.ended_at),
          :duration       => format_duration(task.ended_at, task.started_at),
          :display_size   => task.humanized[:output],
          :size           => task.humanized[:output],
          :is_running     => task.pending && task.state != 'paused',
          :error_details  => task.errors
      }
    else
      empty_task(repo)
    end
  end

  def empty_task(repo)
    state = 'never_synced'
    {   :id             => repo.id,
        :product_id     => repo.product.id,
        :progress       => {},
        :state          => format_state(OpenStruct.new(:state => state)),
        :raw_state      => state
    }
  end

  def raw_state(task)
    if task.result == 'error' || task.result == 'warning'
      return 'error'
    else
      task.state
    end
  end

  def format_state(task)
    @@status_values[raw_state(task)] || task.state
  end

  def format_duration(finish, start)
    retval = nil
    if !finish.nil? && !start.nil?
      retval = distance_of_time_in_words(finish, start)
    end
    retval
  end

  def format_date(check_date)
    retval = nil
    if !check_date.nil?
      retval = relative_time_in_words(check_date)
    end
    retval
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
        collected << format_sync_progress(repo)
      else
        notify.error N_("There is already an active sync process for the '%s' repository. Please try again later") %
                        repo.name
      end
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
