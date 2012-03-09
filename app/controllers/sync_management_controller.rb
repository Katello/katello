#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'resources/pulp'

class SyncManagementController < ApplicationController
  include TranslationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include SyncManagementHelper::RepoMethods
  respond_to :html, :json

  @@status_values = { PulpSyncStatus::Status::WAITING => _("Queued."),
                     PulpSyncStatus::Status::FINISHED => _("Sync complete."),
                     PulpSyncStatus::Status::ERROR => _("Error syncing!"),
                     PulpSyncStatus::Status::RUNNING => _("Running."),
                     PulpSyncStatus::Status::CANCELED => _("Cancelled."),
                     PulpSyncStatus::Status::NOT_SYNCED => ""}


  before_filter :find_provider, :except => [:index, :sync, :sync_status]
  before_filter :find_providers, :only => [:sync, :sync_status]
  before_filter :authorize
  

  def section_id
    'contents'
  end

  def rules

    list_test = lambda{current_organization && Provider.any_readable?(current_organization) }
    sync_read_test = lambda{
      @providers.each{|prov|
        return false if !prov.readable?
      }
      return true
    }
    sync_test = lambda {current_organization && current_organization.syncable?}
    
    { :index => list_test,
      :sync_status => sync_read_test,
      :product_status => sync_read_test,
      :sync => sync_test,
      :destroy => sync_test
    }
  end


  def index
    org = current_organization
    @products = org.library.products.readable(org)
    
    redhat_products = @products.select{ |prod| prod.redhat? }
    custom_products = @products.select{ |prod| !prod.redhat? }
    
    redhat_products.sort! { |p1,p2| p1.name.upcase() <=> p2.name.upcase() }
    custom_products.sort! { |p1,p2| p1.name.upcase() <=> p2.name.upcase() }
    
    @products = redhat_products + custom_products
    
    @sproducts = @products.reject{|prod| !prod.syncable?} # syncable products

    
    @product_size = Hash.new
    @repo_status = Hash.new

    @product_map = collect_repos(@products, org.library)

    for p in @products
      product_size = 0
      for r in p.repos(p.organization.library)
        status = r.sync_status 
        @repo_status[r.id] = format_sync_progress(status, r)
        product_size += status.progress.total_size
      end
      @product_size[p.id] = number_to_human_size(product_size)
    end

    render :index, :locals=>{:status_obj=>@repo_status}
  end

  def sync
    ids = sync_repos(params[:repoids]) || {}
    respond_with (ids) do |format|
      format.js { render :json => ids.to_json, :status => :ok }
    end
  end
 
  def sync_status
    collected = []
    params[:repoids].each do |id|
      begin
        repo = Repository.find(id)
        progress = format_sync_progress(repo.sync_status, repo)
        collected.push(progress)
      rescue Exception => e
        notice e.to_s, {:level => :error} # debugging and skip for now
        next 
      end
    end

    respond_with (collected) do |format|
      format.js { render :json => collected.to_json, :status => :ok }
    end
  end


  def destroy
    retval = Repository.find(params[:id]).cancel_sync
    render :text=>""
  end




private

  def find_provider
    Repository.find(params[:repo] || params[:id]).product.provider
  end

  def find_providers
    ids = params[:repoids]
    ids = [params[:repoids]] if !params[:repoids].is_a? Array
    @providers = []
    ids.each{|id|
      repo = Repository.find(id)
      @providers << repo.product.provider
    }
  end


  def format_sync_progress(sync_status, repo)
    progress = sync_status.progress
    error_details = progress.error_details

    not_running_states = [PulpSyncStatus::Status::FINISHED,
                          PulpSyncStatus::Status::ERROR,
                          PulpSyncStatus::Status::WAITING,
                          PulpSyncStatus::Status::CANCELED,
                          PulpSyncStatus::Status::NOT_SYNCED]
    {   :id             => repo.id,
        :product_id     => repo.product.id,
        :progress       => calc_progress(sync_status),
        :sync_id        => sync_status.uuid,
        :state          => format_state(sync_status.state),
        :raw_state      => sync_status.state,
        :start_time     => format_date(sync_status.start_time),
        :finish_time    => format_date(sync_status.finish_time),
        :duration       => format_duration(sync_status.finish_time, sync_status.start_time),
        :packages       => sync_status.progress.total_count,
        :display_size   => number_to_human_size(sync_status.progress.total_size),
        :size           => sync_status.progress.total_size,
        :is_running     => !not_running_states.include?(sync_status.state.to_sym),
        :error_details  => error_details ? error_details : "No errors."
    }
  end

  def format_state(state)
    @@status_values[state.to_sym]
  end

  def format_duration(finish, start)
    retval = nil
    if !finish.nil? and !start.nil?
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

  # loop through checkbox list of products and sync
  def sync_repos(repos)
    repos = [repos] if !repos.is_a? Array
    collected = []
    repos.each do |id|
      repo = Repository.find(id)
      begin
        resp = repo.sync().first
        collected.push({:id => id, :product_id=>repo.product.id, :state => resp[:state]})
      rescue RestClient::Conflict => e
        notice N_("There is already an active sync process for the '%s' repository. Please try again later") % repo.name, {:level => :error}
      end
    end
    collected
  end

  # calculate the % complete of ongoing sync from pulp
  def calc_progress(val)
    completed = val.progress.total_size - val.progress.size_left
    progress = if val.state =~ /error/i then -1
               elsif val.progress.total_size == 0 then 0
               else completed.to_f / val.progress.total_size.to_f * 100
               end
    retval = {:count => val.progress.total_count,
              :left => val.progress.items_left,
              :progress => progress
             }
  end

  def send_notification(product, status)
    if status.error_details.size > 0 then
      notice _("%s product was synced successfully with errors. See log for details") % product.name,
                                  {:details => status.error_details.join("\n"),:synchronous_request => false}
      status.error_details.each { |d| Rails.logger.error("Sync error:" +  d[:error]) }
    else
      notice _("%s product was synced successfully") % product.name
    end
  end

  def report_error(product)
    notice product.name + ' ' + _("sync did not complete successfully"), {:level => :error, :synchronous_request => false}
    Rails.logger.error product.name + " sync did not complete successfully"
  end
end
