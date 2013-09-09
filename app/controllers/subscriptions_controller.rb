#
# Copyright 2013 Red Hat, Inc.
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
  before_filter :find_subscription, :except => [:index, :items, :new, :upload, :delete_manifest, :history, :history_items, :edit_manifest, :refresh_manifest]
  before_filter :authorize
  before_filter :setup_options, :only => [:index, :items]

  # two pane columns and mapping for sortable fields
  COLUMNS = {'name' => 'name_sort'}

  def rules
    read_provider_test = lambda{@provider.readable?}
    edit_provider_test = lambda{@provider.editable?}
    {
      :index => read_provider_test,
      :items => read_provider_test,
      :edit => read_provider_test,  # Note: edit is the callback for sliding out right panel
      :products => read_provider_test,
      :consumers => read_provider_test,
      :history => read_provider_test,
      :history_items => read_provider_test,
      :new => read_provider_test,
      :upload => edit_provider_test,
      :refresh_manifest => edit_provider_test,
      :delete_manifest => edit_provider_test,
      :edit_manifest => read_provider_test
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
      details = current_organization.owner_details
      if (details['upstreamConsumer'].nil? ||
          (!@provider.task_status.nil? && !@provider.task_status.finish_time))
        @panel_options[:initial_state] = {:panel => :new}
      end
    end

    if current_user.experimental_ui
      render :index_nutupane, :locals => { :experimental_ui => true }
    else
      render :index
    end
  end

  # TODO: remove this method and route since nutupane (experimental mode) uses the api method subscriptions_controller#organization_index
  def items
    query_string = params[:search]
    offset = params[:offset].to_i || 0
    filters = []

    # Limit subscriptions to current org and Red Hat provider
    filters << {:org => [current_organization.label]}
    filters << {:provider_id => [current_organization.redhat_provider.id]}

    options = {
        :filter => filters,
        :load_records? => false,
        :default_field => :name
    }
    options[:page_size] = params[:page_size] || current_user.page_size
    params[:sort_by] ||= :name_sort
    params[:sort_order] ||= 'ASC'
    options.merge!(params.slice(:sort_by, :sort_order))

    # Without any search terms, reindex all subscriptions in elasticsearch. This is to insure
    # that the latest information is searchable.
    if offset == 0 && query_string.blank?
      current_organization.redhat_provider.index_subscriptions
    end

    items = Glue::ElasticSearch::Items.new(Pool)
    subscriptions, total_count = items.retrieve(query_string, offset, options)
    @panel_options[:total_count] = total_count

    render_panel_results(subscriptions, items.total_items, @panel_options)
  end

  def edit
    render :partial => "edit", :locals => {:subscription => @subscription, :editable => false, :name => controller_display_name}
  end

  def products
    render :partial => "products", :locals => {:subscription => @subscription, :editable => false, :name => controller_display_name}
  end

  def consumers
    systems = current_organization.systems.readable(current_organization)
    systems = systems.all_by_pool(@subscription.cp_id)

    activation_keys = ActivationKey.joins(:pools).where('pools.cp_id' => @subscription.cp_id).readable(current_organization)
    activation_keys = [] if !activation_keys

    distributors = current_organization.distributors.readable(current_organization)
    distributors = distributors.all_by_pool(@subscription.cp_id)

    render :partial => "consumers", :locals => {:subscription => @subscription,
                                            :systems => systems,
                                            :activation_keys => activation_keys,
                                            :distributors => distributors,
                                            :editable => false,
                                            :name => controller_display_name}
  end

  def new
    get_manifest_details
    can_refresh = @upstream['idCert'] && @upstream['idCert']['cert']
    render :partial => "new", :locals => {:provider => @provider, :statuses => @statuses, :details => @details, :upstream => @upstream,
                                      :name => controller_display_name, :can_refresh => can_refresh}
  end

  def edit_manifest
    get_manifest_details
    render :partial => "edit_manifest", :locals => {:provider => @provider, :statuses => @statuses, :details => @details, :upstream => @upstream, :name => controller_display_name}
  end

  def history
    begin
      @statuses = @provider.owner_imports
    rescue # rubocop:disable HandleExceptions
      # quietly ignore
    end
    render :template => "subscriptions/_history", :locals => {:provider => @provider, :statuses => @statuses, :name => controller_display_name}
  end

  def history_items
    begin
      @statuses = @provider.owner_imports
    rescue => error
      @statuses = []
      display_message = parse_display_message(error.response)
      error_text = _("Unable to retrieve subscription history for provider '%{name}'." % {:name => @provider.name})
      error_text += _("%{newline}Reason: %{reason}" % {:reason => display_message, :newline => "<br />"}) unless display_message.blank?
      notify.exception error_text, error, :asynchronous => true
      Rails.logger.error "Error fetching subscription history from Candlepin"
      Rails.logger.error error
      Rails.logger.error error.backtrace.join("\n")
      render :partial => "history_items", :status => :bad_request, :locals => {:provider => @provider, :name => controller_display_name, :statuses => @statuses}
      return
    end

    render :partial => "history_items", :locals => {:provider => @provider, :name => controller_display_name, :statuses => @statuses}
  end

  def delete_manifest
    begin
      @provider.delete_manifest :async => true, :notify => true
    rescue => error
      if error.respond_to?(:response)
        display_message = ApplicationController.parse_display_message(error.response)
      elsif error.message
        display_message = error.message
      else
        display_message = ""
      end

      notify.exception @provider.delete_error_message(display_message), error
    end

    render :json => {'state' => 'running'}
  end

  def upload
    if !params[:provider].blank? && params[:provider].has_key?(:contents)
      begin
        temp_file_path = create_temp_file('import') {|tmp| tmp.write params[:provider][:contents].read }
        # force must be a string value
        force_update = params[:force_import] == "1" ? "true" : "false"
        @provider.import_manifest File.expand_path(temp_file_path), :force => force_update,
                                  :async => true, :notify => true
      rescue => error
        if error.respond_to?(:response)
          display_message = ApplicationController.parse_display_message(error.response)
        elsif error.message
          display_message = error.message
        else
          display_message = ""
        end

        notify.exception @provider.import_error_message(display_message), error

        Rails.logger.error "error uploading subscriptions."
        Rails.logger.error error
        Rails.logger.error error.backtrace.join("\n")
        # Fall-through even on error so that the import history is refreshed
      end
    else
      # user didn't provide a manifest to upload
      notify.error _("Subscription manifest must be specified on upload.")
    end

    render :json => {'state' => 'running'}
  end

  def refresh_manifest
    begin
      get_manifest_details # to set @upstream
      @provider.refresh_manifest @upstream, :async => true, :notify => true
    rescue => error
      if error.respond_to?(:response)
        display_message = ApplicationController.parse_display_message(error.response)
      elsif error.message
        display_message = error.message
      else
        display_message = ""
      end

      notify.exception @provider.refresh_error_message(display_message), error
    end

    render :json => {'state' => 'running'}
  end

  def section_id
    'subscriptions'
  end

  private

  def get_manifest_details
    @details = current_organization.owner_details
    @statuses = @provider.owner_imports || []
    @upstream =  @details['upstreamConsumer'].blank? ? {} : @details['upstreamConsumer']

    # Put some manifest-specific information onto the consumer for use in the view
    import_status = @statuses.find {|s| s['upstreamId'] == @upstream['uuid']}
    if !import_status.blank?
      @upstream['generatedBy'] = import_status['generatedBy']
      @upstream['generatedDate'] = import_status['generatedDate']
      @upstream['fileName'] = import_status['fileName']
    end
  end

  def find_or_create_temp_dir
    dir = "#{Rails.root}/tmp"
    Dir.mkdir(dir) unless File.directory? dir
    dir
  end

  def create_temp_file(prefix)
    # default external encoding in Ruby 1.9.3 is UTF-8, need to specify that we are opening a binary file (ASCII-8BIT encoding)
    f = File.new(
        File.join(find_or_create_temp_dir, "#{prefix}_#{SecureRandom.hex(10)}.zip"), 'wb+', 0600)

    yield f if block_given?
    f.path
  ensure
    f.close unless f.nil?
  end

  def split_order(order)
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
                      :ajax_scroll => items_subscriptions_path,
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
