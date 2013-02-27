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

class SystemsController < ApplicationController
  include SystemsHelper

  before_filter :find_system, :except =>[:index, :items, :environments, :new, :create, :bulk_destroy,
                                         :bulk_content_install, :bulk_content_update, :bulk_content_remove,
                                         :bulk_errata_install, :bulk_add_system_group, :bulk_remove_system_group,
                                         :auto_complete]
  before_filter :find_systems, :only=>[:bulk_destroy, :bulk_content_install, :bulk_content_update, :bulk_content_remove,
                                       :bulk_errata_install, :bulk_add_system_group, :bulk_remove_system_group]

  before_filter :find_environment, :only => [:environments, :new]
  before_filter :authorize

  before_filter :setup_options, :only => [:index, :items, :create, :environments]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name_sort', 'lastCheckin' => 'lastCheckin'}

  def rules
    edit_system = lambda{System.find(params[:id]).editable?}
    read_system = lambda{System.find(params[:id]).readable?}
    env_system = lambda{@environment && @environment.systems_readable?}
    any_readable = lambda{current_organization && System.any_readable?(current_organization)}
    delete_systems = lambda{@system.deletable?}
    bulk_delete_systems = lambda{@systems.collect{|s| false unless s.deletable?}.compact.empty?}
    bulk_edit_systems = lambda{@systems.collect{|s| false unless s.editable?}.compact.empty?}
    register_system = lambda { current_organization && System.registerable?(@environment, current_organization) }
    items_test = lambda do
      if params[:env_id]
        @environment = KTEnvironment.find(params[:env_id])
        @environment && @environment.systems_readable?
      else
        current_organization && System.any_readable?(current_organization)
      end
    end
    {
      :index => any_readable,
      :create => register_system,
      :new => register_system,
      :items => items_test,
      :environments => env_system,
      :subscriptions => read_system,
      :update_subscriptions => edit_system,
      :products => read_system,
      :more_products => read_system,
      :update => edit_system,
      :edit => read_system,
      :show => read_system,
      :facts => read_system,
      :auto_complete => any_readable,
      :destroy=> delete_systems,
      :bulk_destroy => bulk_delete_systems,
      :bulk_add_system_group => bulk_edit_systems,
      :bulk_remove_system_group => bulk_edit_systems,
      :bulk_content_install => bulk_edit_systems,
      :bulk_content_update => bulk_edit_systems,
      :bulk_content_remove => bulk_edit_systems,
      :bulk_errata_install => bulk_edit_systems,
      :system_groups => read_system,
      :add_system_groups => edit_system,
      :remove_system_groups => edit_system,
      :custom_info => read_system
    }
  end

  def param_rules
    update_check = lambda do
      if params[:system]
        sys_rules = {:system => [:name, :description, :location, :releaseVer, :serviceLevel, :environment_id, :content_view_id] }
        check_hash_params(sys_rules, params)
      else
        check_array_params([:id], params)
      end
    end
    {   :create => {:arch => [:arch_id],
                    :system=>[:sockets, :name, :environment_id, :content_view_id, :memory],
                    :system_type =>[:virtualized]
                   },
        :update => update_check
    }
  end

  def new
    @system = System.new
    @system.facts = {} #this is nil to begin with
    @organization = current_organization
    accessible_envs = current_organization.environments
    setup_environment_selector(current_organization, accessible_envs)

    # This controls whether the New System page will display an environment selector or not.
    # Since only one selector may exist at a time, it is left off of the New page when the
    # Environments page is displayed.
    envsys = !params[:env_id].nil?

    render :partial=>"new", :locals=>{:system=>@system, :accessible_envs => accessible_envs, :envsys => envsys}
  end

  def create
    @system = System.new
    @system.facts = {}
    @system.arch = params["arch"]["arch_id"]
    @system.sockets = params["system"]["sockets"]
    @system.memory = params["system"]["memory"]
    @system.guest = (params["system_type"]["virtualized"] == 'virtual')
    @system.name= params["system"]["name"]
    @system.cp_type = "system"
    @system.environment = KTEnvironment.find(params["system"]["environment_id"])
    @system.content_view = ContentView.find_by_id(params["system"].try(:[], "content_view_id"))
    #create it in candlepin, parse the JSON and create a new ruby object to pass to the view
    #find the newly created system
    if @system.save!
      notify.success _("System '%s' was created.") % @system['name']

      if search_validate(System, @system.id, params[:search])
        render :partial=>"systems/list_systems",
          :locals=>{:accessor=>"id", :columns=>['name', 'lastCheckin','created' ], :collection=>[@system], :name=> controller_display_name}
      else
        notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @system["name"]
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
    @system_groups = SystemGroup.where(:organization_id => current_organization).order(:name)
  end

  def environments
    accesible_envs = KTEnvironment.systems_readable(current_organization)

    @system_groups = SystemGroup.where(:organization_id => current_organization).order(:name)

    @systems = []
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
    render_panel_direct(System, @panel_options, search, params[:offset], order,
                        {:default_field => :name, :filter=>filters, :load=>true})

  end

  def auto_complete
    query = Katello::Search::filter_input query
    query = "name_autocomplete:#{params[:term]}"
    org = current_organization
    env_ids = KTEnvironment.systems_readable(org).collect{|item| item.id}
    filters = readable_filters
    systems = System.search do
      query do
        string query
      end
      filter :terms, filters
    end
    render :json=>systems.map{|s|
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
    consumed_entitlements = @system.consumed_entitlements.collect do |entitlement|
      pool = ::Pool.find_pool(entitlement.poolId)
      product = Product.where(:cp_id => pool.product_id).first
      entitlement.provider_id = product.try :provider_id
      entitlement
    end

    cp_pools = @system.filtered_pools(current_user.subscriptions_match_system_preference,
                                      current_user.subscriptions_match_installed_preference,
                                      current_user.subscriptions_no_overlap_preference)

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

    # Set up the subscription filters based upon the user prefs
    subscription_filters = "
        <option value='subscriptions_match_system' %s>%s</option>
        <option value='subscriptions_match_installed' %s>%s</option>
        <option value='subscriptions_no_overlap' %s>%s</option>
        " % [ current_user.subscriptions_match_system_preference ? "selected='selected'" : '', _("Match System"),
              current_user.subscriptions_match_installed_preference ? "selected='selected'" : '', _("Match Installed Software"),
              current_user.subscriptions_no_overlap_preference ? "selected='selected'" : '', _("No Overlap with Current")]

    @organization = current_organization
    render :partial=>"subscriptions", :locals=>{:system=>@system, :avail_subs => subscriptions,
                                                :consumed_entitlements => consumed_entitlements,
                                                :editable=>@system.editable?, :subscription_filters=>subscription_filters}
  end

  def update_subscriptions
    if params.has_key? :subscription
      params[:subscription].keys.each do |pool|
        @system.subscribe pool, params[:spinner][pool] if params[:subscribe_action].downcase == "subscribe"
        @system.unsubscribe pool if params[:subscribe_action].downcase == "unsubscribe"
      end
    end
    consumed_entitlements = @system.consumed_entitlements
    avail_pools = @system.available_pools_full
    render :partial=>"subs_update", :locals=>{:system=>@system, :avail_subs => avail_pools,
                                              :consumed_subs => consumed_entitlements,
                                              :editable=>@system.editable?}
    notify.success _("System subscriptions updated.")
  end

  def products
    if @system.class == Hypervisor
      render :partial=>"hypervisor",
             :locals=>{:system=>@system,
                       :message=>_("Hypervisors do not have software products")}
      return
    end

    @products_count = @system.installedProducts.size
    @products, @offset = first_objects @system.installedProducts.sort {|a,b| a['productName'].downcase <=> b['productName'].downcase}
    render :partial=>"products",
           :locals=>{:system=>@system, :products=>@products,:offset=>@offset, :products_count=>@products_count}
  end

  def more_products
    # offset is computed in javascript but this one is used in tests
    @products, @offset = more_objects @system.installedProducts.sort {|a,b| a['productName'].downcase <=> b['productName'].downcase}
    render :partial=>"more_products", :locals=>{:system=>@system, :products=>@products}
  end

  def edit
    begin
      releases = @system.available_releases
    rescue => e
      releases_error = e.to_s
      Rails.logger.error e.to_s
    end
    releases ||= []
    releases_error ||= nil

    # Stuff into var for use in spec tests
    @locals_hash = { :system => @system, :editable => @system.editable?,
                    :releases => releases, :releases_error => releases_error, :name => controller_display_name,
                    :environments => environment_paths(library_path_element, environment_path_element("systems_readable?")) }
    render :partial => "edit", :locals => @locals_hash
  end

  def update
    # The 'autoheal' flag is not an ActiveRecord attribute so update it explicitly if present
    # The 'serviceLevel' comes in as a string 0/1 + level (eg. 0STANDARD = auto off, STANDARD))
    if params[:system] && params[:system][:serviceLevel]
      val = params[:system][:serviceLevel]
      if val == '0'
        params[:system][:serviceLevel] = ''
        @system.autoheal = false
      elsif val == '1'
        params[:system][:serviceLevel] = ''
        @system.autoheal = true
      else
        if val.start_with? '1'
          @system.autoheal = true
        else
          @system.autoheal = false
        end
        params[:system][:serviceLevel] = val[1..-1]
      end
    end

    @system.update_attributes!(params[:system])
    notify.success _("System '%s' was updated.") % @system["name"]

    if !search_validate(System, @system.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @system["name"],
                     :asynchronous => false
    end

    respond_to do |format|
      format.html {
        # Use the systems_helper method when returning service level so the UI reflects proper text
        if params[:system] && params[:system][:serviceLevel]
          render :text=>system_servicelevel(@system)
        else
          render :text=>(params[:system] ? params[:system].first[1] : "")
        end
      }
      format.js
    end
  end

  def custom_info
    render :partial => "edit_custom_info"
  end

  def show
    system = System.find(params[:id])
    render :partial=>"systems/list_system_show", :locals=>{:item=>system, :accessor=>"id", :columns=> COLUMNS.keys, :noblock => 1}
  end

  def section_id
    'systems'
  end

  def facts
    render :partial => 'facts'
  end

  def destroy
    id = params[:id]
    system = find_system
    system.destroy
    if system.destroyed?
      notify.success _("%s Removed Successfully") % system.name
      #render and do the removal in one swoop!
      render :partial => "common/list_remove", :locals => {:id => id, :name=>controller_display_name} and return
    end
    notify.invalid_record system
    render :text => @system.errors, :status=>:ok
  end

  def bulk_destroy
    @systems.each{|sys|
      sys.destroy
    }
    notify.success _("%s Systems Removed Successfully") % @systems.length
    render :text=>""
  end

  def bulk_add_system_group
    successful_systems = []
    failed_systems = []

    unless params[:group_ids].blank?
      @system_groups = SystemGroup.where(:id=>params[:group_ids])

      # perform some pre-validation of the request
      # e.g. are any of the groups not editable or will their membership be exceeded by the request?
      invalid_perms = []
      max_systems_exceeded = []
      @system_groups.each do |system_group|
        if !system_group.editable?
          invalid_perms.push(system_group.name)
        elsif (system_group.max_systems != SystemGroup::UNLIMITED_SYSTEMS) and ((system_group.systems.length + @systems.length) > system_group.max_systems)
          max_systems_exceeded.push(system_group.name)
        end
      end
      if !invalid_perms.empty?
        raise _("System Group membership modification not allowed for group(s): %s") % invalid_perms.join(', ')
      elsif !max_systems_exceeded.empty?
        raise _("System Group maximum number of systems exceeded for group(s): %s") % max_systems_exceeded.join(', ')
      end

      @systems.each do |system|
        begin
          system.system_group_ids = (system.system_group_ids + @system_groups.collect{|g| g.id}).uniq
          system.save!
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action = _("Systems Bulk Action: Add to system group(s): %s") % @system_groups.collect{|g| g.name}.join(', ')
      notify_bulk_action(action, successful_systems, failed_systems)
    end

    render :nothing => true
  end

  def bulk_remove_system_group
    successful_systems = []
    failed_systems = []
    groups_info = {} # hash to store system group id to name mapping
    systems_summary = {} # hash to store system to system group mapping, for groups removed from the system

    unless params[:group_ids].blank?
      @system_groups = SystemGroup.where(:id=>params[:group_ids])

      # does the user have permission to modify the requested system groups?
      invalid_perms = []
      @system_groups.each do |system_group|
        if !system_group.editable?
          invalid_perms.push(system_group.name)
        end
        groups_info[system_group.id] = system_group.name
      end
      if !invalid_perms.empty?
        raise _("System Group membership modification not allowed for group(s): %s") % invalid_perms.join(', ')
      end

      @systems.each do |system|
        begin
          groups_removed = system.system_group_ids & groups_info.keys
          system.system_group_ids = (system.system_group_ids - groups_info.keys).uniq
          system.save!

          systems_summary[system] = groups_removed.collect{|g| groups_info[g]}
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action = _("Systems Bulk Action: Remove from system group(s): %s") % @system_groups.collect{|g| g.name}.join(', ')

      details = []
      systems_summary.each_pair do |system, system_groups|
        details.push(_("System: %{system_name}, System Groups Removed: %{system_group_names}") %
                     {:system_name => system.name, :system_group_names => system_groups.join(', ')})
      end

      notify_bulk_action(action, successful_systems, failed_systems, details.join("\n"))
    end

    render :nothing => true
  end

  def bulk_content_install
    successful_systems = []
    failed_systems = []

    if params[:packages].blank? and params[:groups].blank?
      notify.error _("Systems Bulk Action: No package or package group names have been provided.")
      render :nothing => true and return
    end

    if !params[:packages].blank?
      @systems.each do |system|
        begin
          system.install_packages params[:packages]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action_text = _("Systems Bulk Action: Schedule install of package(s): %s") % params[:packages].join(', ')

    elsif !params[:groups].blank?
      @systems.each do |system|
        begin
          system.install_package_groups params[:groups]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action_text = _("Systems Bulk Action: Schedule install of package group(s): %s") % params[:groups].join(', ')
    end

    notify_bulk_action(action_text, successful_systems, failed_systems)
    render :nothing => true
  end

  def bulk_content_update
    successful_systems = []
    failed_systems = []

    if !params[:groups].blank?
      @systems.each do |system|
        begin
          system.install_package_groups params[:groups]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action_text = _("Systems Bulk Action: Schedule update of package group(s): %s") % params[:groups].join(', ')
    else
      @systems.each do |system|
        begin
          system.update_packages params[:packages]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      params[:packages].blank? ?
        action_text = _("Systems Bulk Action: Schedule update of all packages") :
        action_text = _("Systems Bulk Action: Schedule update of package(s): %s") % params[:packages].join(', ')
    end

    notify_bulk_action(action_text, successful_systems, failed_systems)
    render :nothing => true
  end

  def bulk_content_remove
    successful_systems = []
    failed_systems = []

    if params[:packages].blank? and params[:groups].blank?
      notify.error _("Systems Bulk Action: No package or package group names have been provided.")
      render :nothing => true and return
    end

    if !params[:packages].blank?
      @systems.each do |system|
        begin
          system.uninstall_packages params[:packages]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action_text = _("Systems Bulk Action: Schedule uninstall of package(s): %s") % params[:packages].join(', ')
    elsif !params[:groups].blank?
      @systems.each do |system|
        begin
          system.uninstall_package_groups params[:groups]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
      action_text = _("Systems Bulk Action: Schedule uninstall of package group(s): %s") % params[:groups].join(', ')
    end

    notify_bulk_action(action_text, successful_systems, failed_systems)
    render :nothing => true
  end

  def bulk_errata_install
    successful_systems = []
    failed_systems = []

    if params[:errata].blank?
      notify.error _("Systems Bulk Action: No errata IDs have been provided.")
      render :nothing => true and return
    else
      @systems.each do |system|
        begin
          system.install_errata params[:errata]
          successful_systems.push(system.name)
        rescue => error
          failed_systems.push(system.name)
        end
      end
    end

    action = _("Systems Bulk Action: Schedule install of errata(s): %s") % params[:errata].join(', ')
    notify_bulk_action(action, successful_systems, failed_systems)
    render :nothing => true
  end

  def system_groups
    # retrieve the available groups that aren't currently assigned to the system and that haven't reached their max
    @system_groups = SystemGroup.where(:organization_id=>current_organization).
        select("system_groups.id, system_groups.name").
        joins("LEFT OUTER JOIN system_system_groups ON system_system_groups.system_group_id = system_groups.id").
        group("system_groups.id, system_groups.name, system_groups.max_systems having count(system_system_groups.system_id) < system_groups.max_systems or system_groups.max_systems = -1").
        order(:name) - @system.system_groups

    render :partial=>"system_groups", :locals=>{:editable=>@system.editable?}
  end

  def add_system_groups
    if params[:group_ids].nil? or params[:group_ids].blank?
      notify.error _('One or more system groups must be provided.')
      render :nothing=>true, :status=>500
    else
      ids = params[:group_ids].collect{|g| g.to_i} - @system.system_group_ids #ignore dups
      @system_groups = SystemGroup.where(:id=>ids)
      @system.system_group_ids = (@system.system_group_ids + @system_groups.collect{|g| g.id}).uniq
      @system.save!

      notify.success _("System '%s' was updated.") % @system["name"]
      render :partial =>'system_group_items', :locals=>{:system_groups=>@system_groups} and return
    end
  end

  def remove_system_groups
    system_groups = SystemGroup.where(:id=>params[:group_ids]).collect{|g| g.id}
    @system.system_group_ids = (@system.system_group_ids - system_groups).uniq
    @system.save!

    notify.success _("System '%s' was updated.") % @system["name"]
    render :nothing => true
  end

  private

  include SortColumnList

  def notify_bulk_action(action, successful_systems, failed_systems, details = nil)
    # generate a notice for a bulk action

    success_msg = _("Successful for system(s): ")
    failure_msg = _("Failed for system(s):")
    newline = '<br />'

    if failed_systems.empty?
      notify.success(action + newline + success_msg + successful_systems.join(', '), {:details => details})
    else
      if successful_systems.empty?
        notify.error action + newline + failure_msg + failed_systems.join(', ')
      else
        notify.error(action + newline + success_msg + successful_systems.join(',') +
                     newline + failure_msg + failed_systems.join(','), {:details => details})
      end
    end
  end

  def find_environment
    if current_organization
      readable = KTEnvironment.systems_readable(current_organization)
      @environment = KTEnvironment.find(params[:env_id]) if params[:env_id]
      @environment ||= first_env_in_path(readable, false)
      @environment ||=  current_organization.library
    end
  end

  def find_system
    sys_id = params[:id] || params[:system_id]
    @system = System.find(sys_id)
  end

  def find_systems
    @systems = System.find(params[:ids])
  end

  def setup_options
    @panel_options = {
      :title => _('Systems'),
      :col => ["name_sort", "lastCheckin"],
      :titles => [_("Name"), _("Registered / Last Checked In")],
      :custom_rows => true,
      :enable_create => Katello.config.katello? && System.registerable?(@environment, current_organization),
      :create => _("System"),
      :create_label => _('+ New System'),
      :enable_sort => true,
      :name => controller_display_name,
      :list_partial => 'systems/list_systems',
      :ajax_load  => true,
      :ajax_scroll => items_systems_path(),
      :actions => System.any_deletable?(@environment, current_organization) ? 'actions' : nil,
      :initial_action => :subscriptions,
      :search_class=>System,
      :disable_create=> current_organization.environments.length == 0 ? _("At least one environment is required to create or register systems in your current organization.") : false
    }
  end

  def sys_consumed_pools
    consumed_pools = @system.pools.collect {|pool| OpenStruct.new(:poolId => pool["id"],
                            :poolName => pool["productName"],
                            :startDate => format_time(Date.parse(pool["startDate"])),
                            :endDate => format_time(Date.parse(pool["endDate"])),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    consumed_pools.sort! {|a,b| a.poolName <=> b.poolName}
    consumed_pools
  end

  def sys_available_pools
    avail_pools = @system.available_pools.collect {|pool| OpenStruct.new(:poolId => pool["id"],
                            :poolName => pool["productName"],
                            :startDate => format_time(Date.parse(pool["startDate"])),
                            :endDate => format_time(Date.parse(pool["endDate"])),
                            :consumed => pool["consumed"],
                            :quantity => pool["quantity"])}
    avail_pools.sort! {|a,b| a.poolName <=> b.poolName}
    avail_pools
  end

  def controller_display_name
    return 'system'
  end

  #array constructing a filter
  # to filter readable systems that can be
  # passed to search
  def readable_filters
    {:environment_id=>KTEnvironment.systems_readable(current_organization).collect{|item| item.id}}
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def sort_order_limit systems
    sort_columns(COLUMNS, systems) if params[:order]
    offset = params[:offset].to_i if params[:offset]
    offset ||= 0
    last = offset + current_user.page_size
    last = systems.length if last > systems.length
    systems[offset...last]
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
