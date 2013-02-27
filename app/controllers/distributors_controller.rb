# -*- coding: utf-8 -*-
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

class DistributorsController < ApplicationController
  include DistributorsHelper

  before_filter :find_distributor, :except =>[:index, :items, :environments, :new, :create, :bulk_destroy,
                                         :auto_complete]
  before_filter :find_distributors, :only=>[:bulk_destroy]

  before_filter :find_environment, :only => [:environments, :new]
  before_filter :authorize

  before_filter :setup_options, :only => [:index, :items, :create, :environments]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name_sort', 'lastCheckin' => 'lastCheckin'}

  def rules
    edit_distributor = lambda{Distributor.find(params[:id]).editable?}
    read_distributor = lambda{Distributor.find(params[:id]).readable?}
    env_distributor = lambda{@environment && @environment.distributors_readable?}
    any_readable = lambda{current_organization && Distributor.any_readable?(current_organization)}
    delete_distributors = lambda{@distributor.deletable?}
    bulk_delete_distributors = lambda{@distributors.collect{|s| false unless s.deletable?}.compact.empty?}
    bulk_edit_distributors = lambda{@distributors.collect{|s| false unless s.editable?}.compact.empty?}
    register_distributor = lambda { current_organization && Distributor.registerable?(@environment, current_organization) }
    items_test = lambda do
      if params[:env_id]
        @environment = KTEnvironment.find(params[:env_id])
        @environment && @environment.distributors_readable?
      else
        current_organization && Distributor.any_readable?(current_organization)
      end
    end
    {
      :index => any_readable,
      :create => register_distributor,
      :new => register_distributor,
      :items => items_test,
      :environments => env_distributor,
      :subscriptions => read_distributor,
      :update_subscriptions => edit_distributor,
      :download => read_distributor,
      :products => read_distributor,
      :more_products => read_distributor,
      :update => edit_distributor,
      :edit => read_distributor,
      :show => read_distributor,
      :facts => read_distributor,
      :auto_complete => any_readable,
      :destroy=> delete_distributors,
      :bulk_destroy => bulk_delete_distributors
    }
  end

  def param_rules
    update_check = lambda do
      if params[:distributor]
        sys_rules = {:distributor => [:name, :description, :location, :releaseVer, :serviceLevel, :environment_id, :content_view_id] }
        check_hash_params(sys_rules, params)
      else
        check_array_params([:id], params)
      end
    end
    {
      :create => {:arch => [:arch_id],
                  :distributor=>[:name, :environment_id, :content_view_id],
                  :distributor_type =>[:katello, :headpin]
                 },
      :update => update_check,
      :download => [:id, :filename]
    }
  end

  def new
    @distributor = Distributor.new
    @distributor.facts = {} #this is nil to begin with
    @organization = current_organization
    accessible_envs = current_organization.environments
    setup_environment_selector(current_organization, accessible_envs)

    # This controls whether the New Distributor page will display an environment selector or not.
    # Since only one selector may exist at a time, it is left off of the New page when the
    # Environments page is displayed.
    envsys = !params[:env_id].nil?

    render :partial=>"new", :locals=>{:distributor=>@distributor, :accessible_envs => accessible_envs, :envsys => envsys}
  end

  def create
    @distributor = Distributor.new
    @distributor.facts = {}
    @distributor.name= params["distributor"]["name"]
    @distributor.cp_type = "candlepin"  # The 'candlepin' type is allowed to export a manifest
    @distributor.environment = KTEnvironment.find(params["distributor"]["environment_id"])
    @distributor.content_view = ContentView.find_by_id(params["system"].try(:[], "content_view_id"))
    #create it in candlepin, parse the JSON and create a new ruby object to pass to the view
    #find the newly created distributor
    if @distributor.save!
      notify.success _("Distributor '%s' was created.") % @distributor['name']

      if search_validate(Distributor, @distributor.id, params[:search])
        render :partial=>"distributors/list_distributors",
          :locals=>{:accessor=>"id", :columns=>['name', 'lastCheckin','created' ], :collection=>[@distributor], :name=> controller_display_name}
      else
        notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @distributor["name"]
        render :json => { :no_match => true }
      end
    end

  rescue ActiveRecord::RecordInvalid => error
    raise error # handle error by ApplicationController's rescue_from
  rescue => error
    display_message = if error.respond_to?('response') && error.response.include?('displayMessage')
                         JSON.parse(error.response)['displayMessage']
                      end
    notify.exception *[display_message, error].compact
    Rails.logger.error error.backtrace.join("\n")
    render :text => error, :status => :bad_request
  end

  def index
    # empty
  end

  def environments
    accesible_envs = KTEnvironment.distributors_readable(current_organization)

    @distributors = []
    setup_environment_selector(current_organization, accesible_envs)
    if @environment
      # add the environment id as a search filter.. this will be passed to the app by search as part of
      # the auto_complete_search requests
      @panel_options[:search_env] = @environment.id
    end

    render :index, :locals=>{:envsys => true, :accessible_envs=> accesible_envs}
  end

  def items
    order = split_order(params[:order])
    search = params[:search]
    if params[:env_id]
      find_environment
      filters = {:environment_id=>[params[:env_id]]}
    else
      filters = readable_filters
    end
    render_panel_direct(Distributor, @panel_options, search, params[:offset], order,
                        {:default_field => :name, :filter=>filters, :load=>true})

  end

  def auto_complete
    query = Katello::Search::filter_input query
    query = "name_autocomplete:#{params[:term]}"
    org = current_organization
    env_ids = KTEnvironment.distributors_readable(org).collect{|item| item.id}
    filters = readable_filters
    distributors = Distributor.search do
      query do
        string query
      end
      filter :terms, filters
    end
    render :json=>distributors.map{|s|
      label = _("%{name} (Registered: %{time})") % {:name => s.name, :time => convert_time(format_time(Time.parse(s.created_at)))}
      {:label=>label, :value=>s.name, :id=>s.id}
    }
  rescue Tire::Search::SearchRequestFailed => e
    render :json=>Util::Support.array_with_total
  end


  def split_order(order)
    if order
      order.split("|")
    else
      [:name_sort, "ASC"]
    end

  end

  # Note that finding the provider_id is important to allow the subscription to be linked to the url for either the
  # Red Hat provider or the custom provider page
  def subscriptions
    # Consumed subscriptions
    consumed_entitlements = @distributor.consumed_entitlements.collect do |entitlement|
      pool = ::Pool.find_pool(entitlement.poolId)
      product = Product.where(:cp_id => pool.product_id).first
      entitlement.provider_id = product.try :provider_id
      entitlement
    end

    cp_pools = @distributor.filtered_pools

    if cp_pools
      # Pool objects
      pools = cp_pools.collect{|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}

      subscriptions = pools.collect do |pool|
        product = Product.where(:cp_id => pool.product_id).first
        next if product.nil?
        pool.provider_id = product.provider_id
        pool
      end.compact
      subscriptions = [] if subscriptions.nil?
    else
      subscriptions = []
    end

    @organization = current_organization
    render :partial=>"subscriptions", :locals=>{:distributor=>@distributor, :avail_subs => subscriptions,
                                                :consumed_entitlements => consumed_entitlements,
                                                :editable=>@distributor.editable?}
  end

  def update_subscriptions
    if params.has_key? :subscription
      params[:subscription].keys.each do |pool|
        @distributor.subscribe pool, params[:spinner][pool] if params[:subscribe_action].downcase == "subscribe"
        @distributor.unsubscribe pool if params[:subscribe_action].downcase == "unsubscribe"
      end
    end
    consumed_entitlements = @distributor.consumed_entitlements
    avail_pools = @distributor.available_pools_full
    render :partial=>"subs_update", :locals=>{:distributor=>@distributor, :avail_subs => avail_pools,
                                              :consumed_subs => consumed_entitlements,
                                              :editable=>@distributor.editable?}
    notify.success _("Distributor subscriptions updated.")
  end

  def products
    if @distributor.class == Hypervisor
      render :partial=>"hypervisor",
             :locals=>{:distributor=>@distributor,
                       :message=>_("Hypervisors do not have software products")}
      return
    end

    @products_count = @distributor.installedProducts.size
    @products, @offset = first_objects @distributor.installedProducts.sort {|a,b| a['productName'].downcase <=> b['productName'].downcase}
    render :partial=>"products",
           :locals=>{:distributor=>@distributor, :products=>@products,:offset=>@offset, :products_count=>@products_count}
  end

  def more_products
    # offset is computed in javascript but this one is used in tests
    @products, @offset = more_objects @distributor.installedProducts.sort {|a,b| a['productName'].downcase <=> b['productName'].downcase}
    render :partial=>"more_products", :locals=>{:distributor=>@distributor, :products=>@products}
  end

  def edit
    begin
      releases = @distributor.available_releases
    rescue => e
      releases_error = e.to_s
      Rails.logger.error e.to_s
    end
    releases ||= []
    releases_error ||= nil

    # Stuff into var for use in spec tests
    @locals_hash = { :distributor => @distributor, :editable => @distributor.editable?,
                    :releases => releases, :releases_error => releases_error, :name => controller_display_name,
                    :environments => environment_paths(library_path_element, environment_path_element("distributors_readable?")) }
    render :partial => "edit", :locals => @locals_hash
  end

  def update
    # The 'autoheal' flag is not an ActiveRecord attribute so update it explicitly if present
    # The 'serviceLevel' comes in as a string 0/1 + level (eg. 0STANDARD = auto off, STANDARD))
    if params[:distributor] && params[:distributor][:serviceLevel]
      val = params[:distributor][:serviceLevel]
      if val == '0'
        params[:distributor][:serviceLevel] = ''
        @distributor.autoheal = false
      elsif val == '1'
        params[:distributor][:serviceLevel] = ''
        @distributor.autoheal = true
      else
        if val.start_with? '1'
          @distributor.autoheal = true
        else
          @distributor.autoheal = false
        end
        params[:distributor][:serviceLevel] = val[1..-1]
      end
    end

    @distributor.update_attributes!(params[:distributor])
    notify.success _("Distributor '%s' was updated.") % @distributor["name"]

    if not search_validate(Distributor, @distributor.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @distributor["name"],
                     :asynchronous => false
    end

    respond_to do |format|
      format.html {
        # Use the distributors_helper method when returning service level so the UI reflects proper text
        if params[:distributor] && params[:distributor][:serviceLevel]
          render :text=>distributor_servicelevel(@distributor)
        else
          render :text=>(params[:distributor] ? params[:distributor].first[1] : "")
        end
      }
      format.js
    end
  end

  def show
    distributor = Distributor.find(params[:id])
    render :partial=>"distributors/list_distributor_show", :locals=>{:item=>distributor, :accessor=>"id", :columns=> COLUMNS.keys, :noblock => 1}
  end

  def section_id
    'distributors'
  end

  def destroy
    id = params[:id]
    distributor = find_distributor
    distributor.destroy
    if distributor.destroyed?
      notify.success _("%s Removed Successfully") % distributor.name
      #render and do the removal in one swoop!
      render :partial => "common/list_remove", :locals => {:id => id, :name=>controller_display_name} and return
    end
    notify.invalid_record distributor
    render :text => @distributor.errors, :status=>:ok
  end

  def bulk_destroy
    @distributors.each{|sys|
      sys.destroy
    }
    notify.success _("%s Distributors Removed Successfully") % @distributors.length
    render :text=>""
  end

  def download
    filename = params[:filename]
    filename = 'manifest.zip' if filename.nil? || filename == ''

    data = @distributor.export
    send_data data,
              :filename => filename,
              :type => 'application/xml'
  end

  private

  include SortColumnList

  def notify_bulk_action(action, successful_distributors, failed_distributors, details = nil)
    # generate a notice for a bulk action

    success_msg = _("Successful for distributor(s): ")
    failure_msg = _("Failed for distributor(s):")
    newline = '<br />'

    if failed_distributors.empty?
      notify.success(action + newline + success_msg + successful_distributors.join(', '), {:details => details})
    else
      if successful_distributors.empty?
        notify.error action + newline + failure_msg + failed_distributors.join(', ')
      else
        notify.error(action + newline + success_msg + successful_distributors.join(',') +
                     newline + failure_msg + failed_distributors.join(','), {:details => details})
      end
    end
  end

  def find_environment
    if current_organization
      readable = KTEnvironment.distributors_readable(current_organization)
      @environment = KTEnvironment.find(params[:env_id]) if params[:env_id]
      @environment ||= first_env_in_path(readable, false)
      @environment ||=  current_organization.library
    end
  end

  def find_distributor
    @distributor = Distributor.find(params[:id])
  end

  def find_distributors
    @distributors = Distributor.find(params[:ids])
  end

  def setup_options
    @panel_options = {
      :title => _('Distributors'),
      :col => ["name_sort", "lastCheckin"],
      :titles => [_("Name"), _("Created / Last Checked In")],
      :custom_rows => true,
      :enable_create => Katello.config.katello? && Distributor.registerable?(@environment, current_organization),
      :create => _("Distributor"),
      :create_label => _('+ New Distributor'),
      :enable_sort => true,
      :name => controller_display_name,
      :list_partial => 'distributors/list_distributors',
      :ajax_load  => true,
      :ajax_scroll => items_distributors_path(),
      :actions => Distributor.any_deletable?(@environment, current_organization) ? 'actions' : nil,
      :initial_action => :subscriptions,
      :search_class=>Distributor,
      :disable_create=> current_organization.environments.length == 0 ? _("At least one environment is required to create or register distributors in your current organization.") : false
    }
  end

  def sys_consumed_pools
    consumed_pools = @distributor.pools.collect {|pool| OpenStruct.new(:poolId => pool["id"],
                            :poolName => pool["productName"],
                            :startDate => format_time(Date.parse(pool["startDate"])),
                            :endDate => format_time(Date.parse(pool["endDate"])),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    consumed_pools.sort! {|a,b| a.poolName <=> b.poolName}
    consumed_pools
  end

  def sys_available_pools
    avail_pools = @distributor.available_pools.collect {|pool| OpenStruct.new(:poolId => pool["id"],
                            :poolName => pool["productName"],
                            :startDate => format_time(Date.parse(pool["startDate"])),
                            :endDate => format_time(Date.parse(pool["endDate"])),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    avail_pools.sort! {|a,b| a.poolName <=> b.poolName}
    avail_pools
  end

  def controller_display_name
    return 'distributor'
  end

  #array constructing a filter
  # to filter readable distributors that can be
  # passed to search
  def readable_filters
    {:environment_id=>KTEnvironment.distributors_readable(current_organization).collect{|item| item.id}}
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def sort_order_limit distributors
    sort_columns(COLUMNS, distributors) if params[:order]
    offset = params[:offset].to_i if params[:offset]
    offset ||= 0
    last = offset + current_user.page_size
    last = distributors.length if last > distributors.length
    distributors[offset...last]
  end

  def first_objects objects
    offset = current_user.page_size
    if objects.length > 0
      if params.has_key? :order
        if params[:order].downcase == "desc"
          objects.reverse!
        end
      end
      objects = objects[0...offset]
    else
      objects = []
    end
    return objects, offset
  end

  def more_objects objects
    #grab the current user setting for page size
    size = current_user.page_size
    if objects.length > 0
      #check for the params offset (start of array chunk)
      if params.has_key? :offset
        offset = params[:offset].to_i
      else
        offset = current_user.page_size
      end
      if params.has_key? :order
        if params[:order].downcase == "desc"
          #reverse if order is desc
          objects.reverse!
        end
      end
      if params.has_key? :reverse
        next_objects = objects[0...params[:reverse].to_i]
      else
        next_objects = objects[offset...offset+size]
      end
      next_objects ||= [] # fence for case when offset extended beyond range, etc.
    else
      next_objects = []
    end

    return next_objects, offset+size
  end

end
