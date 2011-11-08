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

  respond_to :html, :json

  @@status_values = { PulpSyncStatus::Status::WAITING => _("Queued."),
                     PulpSyncStatus::Status::FINISHED => _("Sync complete."),
                     PulpSyncStatus::Status::ERROR => _("Error syncing!"),
                     PulpSyncStatus::Status::RUNNING => _("Running."),
                     PulpSyncStatus::Status::CANCELED => _("Canceled."),
                     PulpSyncStatus::Status::NOT_SYNCED => ""}


  before_filter :find_provider, :except => [:index, :sync, :sync_status]
  before_filter :find_providers, :only => [:sync, :sync_status]
  before_filter :authorize
  

  def section_id
    'contents'
  end



  def rules

    list_test = lambda{Provider.any_readable?(current_organization) }
    sync_read_test = lambda{
      @providers.each{|prov|
        return false if !prov.readable?
      }
      return true
    }
    sync_test = lambda {current_organization.syncable?}
    
    { :index => list_test,
      :sync_status => sync_read_test,
      :product_status => sync_read_test,
      :sync => sync_test,
      :destroy => sync_test
    }
  end


  def index
    org = current_organization
    @products = org.locker.products.readable(org).reject { |p| p.repos(p.organization.locker).empty? }
    @products.sort! { |p1,p2| p1.name.upcase() <=> p2.name.upcase() }
    @sproducts = @products.reject{|prod| !prod.syncable?} # syncable products
    
    @product_status = Hash.new
    @product_size = Hash.new
    @repo_status = Hash.new
    @product_repos = {}

    Glue::Pulp::Repos.prepopulate! @products, org.locker

    for p in @products
      pstatus = p.sync_status
      @product_repos[p.id] =  []
      @product_status[p.id] = format_sync_progress(pstatus)
      @product_size[p.id] = number_to_human_size(p.sync_size)
      for r in p.repos(p.organization.locker)
        @product_repos[p.id] << r
        @repo_status[r.id] = format_sync_progress(r.sync_status)
      end
    end

    @product_map = collect_repos(@products)
    
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
        sync_status = Repository.find(id).sync_status
        progress = format_sync_progress(sync_status)
        progress[:repo_id] = id
        collected.push(progress)
      rescue Exception => e
        errors e.to_s # debugging and skip for now
        next 
      end
    end

    respond_with (collected) do |format|
      format.js { render :json => collected.to_json, :status => :ok }
    end
  end

  def product_status
    product = Product.first(:conditions => {:id => params['product_id']})
    repo_stat = Repository.find_by_pulp_id(params[:repo_id]).sync_status
    status = product.sync_status 
    send_notification(product, repo_stat) if status.state == PulpSyncStatus::Status::FINISHED
    report_error(product) if status.state == PulpSyncStatus::Status::ERROR

    progress = format_sync_progress(status)
    progress[:product_id] = params['product_id']
    progress[:size] = number_to_human_size(product.sync_size)
    progress[:repo_id] = params['repo_id']
    respond_with (progress) do |format|
      format.js { render :json => progress.to_json, :status => :ok }
    end
  end

  def destroy
    retval = Pulp::Repository.cancel(params[:id], params[:id])
    cancel =  {:sync_id => retval[:id], :state => retval[:state] }
    respond_with (cancel) do |format|
      format.js { render :json => cancel.to_json, :status => :ok }
    end
  end




private

  def find_provider
    Repository.find(params[:repo]).product.provider
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


  def format_sync_progress(sync_status)
    not_running_states = [PulpSyncStatus::Status::FINISHED,
                          PulpSyncStatus::Status::ERROR,
                          PulpSyncStatus::Status::CANCELED]
    { 
        :progress   => calc_progress(sync_status),
        :sync_id    => sync_status.uuid,
        :state      => format_state(sync_status.state),
        :raw_state  => sync_status.state,
        :start_time => format_date(sync_status.start_time),
        :finish_time=> format_date(sync_status.finish_time),
        :duration   => format_duration(sync_status.finish_time, sync_status.start_time),
        :packages   => sync_status.progress.total_count,
        :size       => number_to_human_size(sync_status.progress.total_size),
        :is_running => !not_running_states.include?(sync_status.state.to_sym)
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
      begin
        resp = Repository.find(id).sync().first
      rescue RestClient::Conflict => e
        r = Repository.find(id)
        errors N_("There is already an active sync process for the '#{r.name}' repository. Please try again later")
        next
      end
      collected.push({:id => id, :state => resp[:state]})
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
      notice _("#{product.name} product was synced successfully with errors. See log for details"),
                                  {:details => status.error_details.join("\n"),:synchronous_request => false}
      status.error_details.each { |d| Rails.logger.error("Sync error:" +  d[:error]) }
    else
      notice _("#{product.name} product was synced successfully")
    end
  end

  def report_error(product)
    errors product.name + ' ' + _("sync did not complete successfully"), {:synchronous_request => false}
    Rails.logger.error product.name + " sync did not complete successfully"
  end


  def collect_repos products
    list = []
    products.each{|prod|
      majors = []
      major_map, non_found_repos = collect_majors(prod)
      major_map.each{|major, major_repos|
        minors = []
        collect_release(major_repos).each{|minor, minor_repos|
          arches = []
          collect_arches(minor_repos).each{|arch, arch_repos|
            arches << {:name=>arch, :id=>arch, :type=>"arch", :children=>[], :repos=>arch_repos}
          }
          minors << {:name=>minor, :id=>minor, :type=>"minor", :children=>arches, :repos=>[]}
        }
        majors << {:name=>major, :id=>major, :type=>"major", :children=>minors, :repos=>[]}
      }
      list << {:name=>prod.name, :id=>prod.id, :type=>"product",  :repos=>non_found_repos, :children=>majors}
    }
    list
  end


  def collect_majors prod
    majors = {}
    non_major = [] #list of repos that don't have a major version
    prod.repos(current_organization.locker).each{|r|
      if r.major_version
        majors[r.major_version] ||= []
        majors[r.major_version] << r
      else
        non_major << r
      end

    }
    [majors, non_major]
  end

  def collect_release repos
    release = {}
    repos.each{|r|
      release[r.release] ||= []
      release[r.release] << r
    }
    release
  end

  def collect_arches repos
    arches = {}
    repos.each{|r|
      arches[r.arch] ||= [ ]
      arches[r.arch] << r
    }
    arches
  end

  #Used for debugging collect_repos output
  def pprint_collection coll
    coll.each{|prod|
      Rails.logger.error prod[:name]
      prod[:children].each{|major|
        Rails.logger.error major[:name]
        major[:children].each{|minor|
          Rails.logger.error minor[:name]
          minor[:children].each{|arch|
            Rails.logger.error arch[:repos].length
          }
        }
      }
    }
  end


end
