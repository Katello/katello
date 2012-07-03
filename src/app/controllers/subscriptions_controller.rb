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
require 'ostruct'

# TODO: index provided products fields for better search
# TODO: start / end dates in left subscriptions list
# TODO: start date range not working?  start:2012-01-31 fails but start:"2012-01-31" works


class SubscriptionsController < ApplicationController

  before_filter :find_provider
  before_filter :find_subscription, :except=>[:index, :items, :new, :upload, :history, :history_items]
  before_filter :authorize
  before_filter :setup_options, :only=>[:index, :items]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name_sort'}

  def rules
    read_provider_test = lambda{@provider.readable?}
    edit_provider_test = lambda{@provider.editable?}
    {
      :index => read_provider_test,
      :items => read_provider_test,
      :show => read_provider_test,
      :edit => read_provider_test,  # Note: edit is the callback for sliding out right panel
      :products => read_provider_test,
      :consumers => read_provider_test,
      :history => read_provider_test,
      :history_items=> read_provider_test,
      :new => read_provider_test,
      :upload => edit_provider_test
    }
  end

  def param_rules
    {
        # empty
    }
  end

  def index
    # If no manifest imported yet or one is currently being imported, open the "new" panel.
    # Originally had intended to open the "new" panel when last import was an error, but this
    # is too restrictive, preventing viewing of previously imported subscriptions.
    if @provider.editable?
      imports = @provider.owner_imports
      if imports.length == 0 || (!@provider.task_status.nil? && !@provider.task_status.finish_time)
        @panel_options[:initial_state] = {:panel => :new}
      end
    end
  end

  def items
    order = split_order(params[:order])
    search = params[:search]
    offset = params[:offset].to_i || 0
    filters = {}

    # Without any search terms, all subscriptions for an org are queried directly from candlepin instead of
    # hitting elastic search. This is important since this is then only time subscriptions get reindexed
    # currently.
    # Note: This does open the possibility that the elastic search contents will be out of date compared to
    #       what is actually in candlepin. This could only happen, though, if the user was performing a
    #       search and didn't refresh the page while the data was changing behind the scenes. Until this
    #       becomes a specific issue, re-indexing will not be performed constantly.
    if search.nil?
      # Raw candlepin pools
      cp_pools = Resources::Candlepin::Owner.pools(current_organization.cp_key)
      if cp_pools
        # Pool objects
        pools = cp_pools.collect{|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}

        # Limit subscriptions to just those from Red Hat provider
        subscriptions = pools.collect do |pool|
          product = Product.where(:cp_id => pool.product_id, :provider_id => current_organization.redhat_provider.id).first
          next if product.nil?
          pool.provider_id = product.provider_id   # Set so it is saved into elastic search
          pool
        end.compact
        subscriptions = [] if subscriptions.nil?

        # Index pools
        # Note: Only the Red Hat provider subscriptions are being indexed.
        ::Pool.index_pools(subscriptions) if subscriptions.length > 0
      else
        subscriptions = []
      end

      if offset != 0
        render :text => "" and return if subscriptions.empty?
      end
      render_panel_items(subscriptions, @panel_options, nil, offset.to_s)
    else
      # Limit subscriptions to current org and Red Hat provider
      filters = {:org=>current_organization.cp_key, :provider_id=>current_organization.redhat_provider.id}
      search_results = ::Pool.search(search, offset, current_user.page_size, filters)
      render_panel_results(search_results, search_results.total, @panel_options)
    end
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:subscription => @subscription, :editable => false, :name => controller_display_name}
  end

  def show
    @provider = current_organization.redhat_provider
    render :partial=>"subscriptions/list_subscription_show", :locals=>{:item=>@subscription, :columns => COLUMNS.keys, :noblock => 1}
  end

  def products
    render :partial=>"products", :layout => "tupane_layout", :locals=>{:subscription=>@subscription, :editable => false, :name => controller_display_name}
  end

  def consumers
    systems = current_organization.systems.readable(current_organization)
    systems = systems.all_by_pool(@subscription.cp_id)

    activation_keys = ActivationKey.joins(:pools).where('pools.cp_id'=>@subscription.cp_id).readable(current_organization)
    activation_keys = [] if !activation_keys

    render :partial=>"consumers", :layout => "tupane_layout", :locals=>{:subscription=>@subscription, :systems=>systems, :activation_keys=>activation_keys, :editable => false, :name => controller_display_name}
  end

  def new
    begin
      @statuses = @provider.owner_imports
    rescue => error
      # quietly ignore
    end
    render :partial=>"new", :layout =>"tupane_layout", :locals=>{:provider=>@provider, :statuses=>@statuses, :name => controller_display_name}
  end

  def history
    begin
      @statuses = @provider.owner_imports
    rescue => error
      # quietly ignore
    end
    render :template => "subscriptions/_history", :locals=>{:provider=>@provider, :statuses=>@statuses, :name => controller_display_name}
  end

  def history_items
    begin
      @statuses = @provider.owner_imports
    rescue => error
      @statuses = []
      display_message = parse_display_message(error.response)
      error_text = _("Unable to retrieve subscription history for provider '%{name}." % {:name => @provider.name})
      error_text += _("%{newline}Reason: %{reason}" % {:reason => display_message, :newline => "<br />"}) unless display_message.blank?
      notice error_text, {:level => :error, :synchronous_request => false}
      Rails.logger.error "Error fetching subscription history from Candlepin"
      Rails.logger.error error
      Rails.logger.error error.backtrace.join("\n")
      render :partial=>"history_items", :layout =>"tupane_layout", :status => :bad_request, :locals=>{:provider=>@provider, :name => controller_display_name, :statuses=>@statuses}
      return
    end

    render :partial=>"history_items", :layout =>"tupane_layout", :locals=>{:provider=>@provider, :name => controller_display_name, :statuses=>@statuses}
  end


  def upload
    if !params[:provider].blank? and params[:provider].has_key? :contents
      temp_file = nil
      begin
        dir = "#{Rails.root}/tmp"
        Dir.mkdir(dir) unless File.directory? dir
        temp_file = File.new(File.join(dir, "import_#{SecureRandom.hex(10)}.zip"), 'w+', 0600)
        temp_file.write params[:provider][:contents].read
        temp_file.close
        # force must be a string value
        force_update = params[:force_import] == "1" ? "true" : "false"
        @provider.import_manifest File.expand_path(temp_file.path), :force => force_update, :async => true,
                                  :notify => true
      rescue => error
        if error.respond_to?(:response)
          display_message = parse_display_message(error.response)
        elsif error.message
          display_message = error.message
        else
          display_message = ""
        end

        error_texts = [
            _("Subscription manifest upload for provider '%s' failed.") % @provider.name,
            (_("Reason: %s") % display_message unless display_message.blank?),
            (_("If you are uploading an older manifest, you can use the Force checkbox to overwrite " +
                   "existing data.") if force_update == "false")
        ].compact

        notice error_texts.join('<br />'), {:level => :error, :details => pp_exception(error)}

        Rails.logger.error "error uploading subscriptions."
        Rails.logger.error error
        Rails.logger.error error.backtrace.join("\n")
        # Fall-through even on error so that the import history is refreshed
      end
    else
      # user didn't provide a manifest to upload
      notice _("Subscription manifest must be specified on upload."), {:level => :error}
    end

    # "finished" is checked for in the javascript to see if polling for task progress should be done
    progress = !@provider.task_status ? "finished" : @provider.task_status.state
    to_ret = {'progress' => progress}
    render :json=>to_ret
  end

  def section_id
    'subscriptions'
  end

  private

  def split_order order
    if order
      order.split
    else
      [:name_sort, "ASC"]
    end
  end

  def find_subscription
    @subscription = ::Pool.find_pool(params[:id])
  end

  def setup_options
    @panel_options = { :title => _('Subscriptions'),
                      :col => ["name"],
                      :titles => [_("Name")],
                      :custom_rows => true,
                      :enable_create => @provider.editable?,
                      :create_label => _("+ Import Manifest"),
                      :enable_sort => true,
                      :name => controller_display_name,
                      :list_partial => 'subscriptions/list_subscriptions',
                      :ajax_load  => true,
                      :ajax_scroll => items_subscriptions_path(),
                      :actions => nil,
                      :search_class => ::Pool,
                      :accessor => 'unused'
                      }
  end

  def controller_display_name
    return 'subscription'
  end

  def find_provider
      @provider = current_organization.redhat_provider
  end

end
