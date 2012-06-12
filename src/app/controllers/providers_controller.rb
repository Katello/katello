
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

class ProvidersController < ApplicationController
  include AutoCompleteSearch

  before_filter :find_rh_provider, :only => [:redhat_provider]

  before_filter :find_provider, :only => [:products_repos, :show, :edit, :update, :destroy, :import_progress]
  before_filter :authorize #after find_provider
  before_filter :panel_options, :only => [:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    index_test = lambda{current_organization && Provider.any_readable?(current_organization)}
    create_test = lambda{current_organization && Provider.creatable?(current_organization)}
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    delete_test = lambda{@provider.deletable?}
    {
      :index => index_test,
      :items => index_test,
      :show => index_test,
      :auto_complete_search => index_test,
      :new => create_test,
      :create => create_test,
      :edit =>read_test,
      :update => edit_test,
      :destroy => delete_test,
      :products_repos => read_test,
      :import_progress => edit_test,

      :redhat_provider =>read_test,
    }
  end

  def param_rules
    {
        :create => {:provider => [:name, :description]},
    }
  end


  def products_repos
    @products = @provider.products
    render :partial => "products_repos", :layout => "tupane_layout", :locals => {:provider => @provider,
                                         :providers => @providers, :products => @products, :editable=>@provider.editable?}
  end

  def import_progress
    expire_page :action => :import_progress
    # "finished" is checked for in the javascript to see if polling for task progress should be done
    if @provider.import_task.nil?
      to_ret = {'state' => 'finished'}
    else
      to_ret = @provider.import_task.to_json
    end

    # Never cache these results since the user may close and re-open the "new" panel and no status would
    # be available for checking
    response.headers["Last-Modified"] = Time.now.httpdate
    response.headers["Expires"] = "0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'

    render :json=>to_ret
  end

  def redhat_provider
=begin
    # We default to none imported until we can properly poll Candlepin for status of the import
    @grouped_subscriptions = []
    begin
      find_subscriptions
    rescue Exception => error
      display_message = parse_display_message(error.response)
      error_text = _("Unable to retrieve subscription manifest for provider '%s'.") % @provider.name
      error_text += "<br />" + _("Reason: %s") % display_message unless display_message.blank?
      notice error_text, {:level => :error, :synchronous_request => false}
      Rails.logger.error "Error fetching subscriptions from Candlepin"
      Rails.logger.error error
      Rails.logger.error error.backtrace.join("\n")
      render :template =>"providers/redhat/show", :status => :bad_request and return
    end

    begin
      @statuses = @provider.owner_imports
    rescue Exception => error
      @statuses = []
      display_message = parse_display_message(error.response)
      error_text = _("Unable to retrieve subscription history for provider '%s'.") % @provider.name
      error_text += "<br />" + _("Reason: %s") % display_message unless display_message.blank?
      notice error_text, {:level => :error, :synchronous_request => false}
      Rails.logger.error "Error fetching subscription history from Candlepin"
      Rails.logger.error error
      Rails.logger.error error.backtrace.join("\n")
      render :template =>"providers/redhat/show", :status => :bad_request and return
    end
=end
    render :template =>"providers/redhat/show"
  end

  def items
    ids = Provider.readable(current_organization).collect{|p| p.id}
    render_panel_direct(Provider, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
                  {:default_field => :name, :filter=>[{"id"=>ids}, {:provider_type=>[Provider::CUSTOM.downcase]}]})
  end

  def show
    provider = Provider.find(params[:id])
    render :partial=>"common/list_update", :locals=>{:item=>provider, :accessor=>"id", :columns=>['name']}
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:provider => @provider, :editable=>@provider.editable?,
                                                                       :name=>controller_display_name}
  end

  def new
    @provider = Provider.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:provider => @provider}
  end

  def create
    begin
      @provider = Provider.create! params[:provider].merge({:provider_type => Provider::CUSTOM,
                                                                    :organization => current_organization})
      notice _("Provider '%s' was created.") % @provider['name']
      
      if search_validate(Provider, @provider.id, params[:search])
        render :partial=>"common/list_item", :locals=>{:item=>@provider, :initial_action=>:products_repos, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
      else
        notice _("'%s' did not meet the current search criteria and is not being shown.") % @provider["name"], { :level => 'message', :synchronous_request => false }
        render :json => { :no_match => true }
      end
    rescue Exception => error
      Rails.logger.error error.to_s
      notice error, {:level => :error}
      render :text => error, :status => :bad_request
    end
  end

  def destroy
    @id = @provider.id
    begin
      @provider.destroy
      if @provider.destroyed?
        notice _("Provider '%s' was deleted.") % @provider[:name]
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      else
        raise
      end
    rescue Exception => e
      notice e.to_s, {:level => :error}
    end
  end

  def update

    begin
      updated_provider = Provider.find(params[:id])
      result = params[:provider].values.first

      updated_provider.name = params[:provider][:name] unless params[:provider][:name].nil?

      unless params[:provider][:description].nil?
        result = updated_provider.description = params[:provider][:description].gsub("\n",'')
      end

      updated_provider.repository_url = params[:provider][:repository_url] unless params[:provider][:repository_url].nil?
      updated_provider.provider_type = params[:provider][:provider_type] unless params[:provider][:provider_type].nil?

      updated_provider.save!
      notice _("Provider '%s' was updated.") % updated_provider.name

      if not search_validate(Provider, updated_provider.id, params[:search])       
        notice _("'%s' no longer matches the current search criteria.") % updated_provider["name"], { :level => 'message', :synchronous_request => false }
      end

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

    rescue Exception => e
      notice e.to_s, {:level => :error}

      respond_to do |format|
        format.html { render :partial => "common/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.json { render :partial => "common/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  protected

  def find_provider
    begin
      @provider = Provider.find(params[:id])
    rescue Exception => error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_rh_provider
      @provider = current_organization.redhat_provider
  end


  def panel_options
    @panel_options = { :title => _('Providers'),
             :col => ['name'],
             :titles => [_('Name')],
             :create => _('Provider'),
             :create_label => _('+ New Provider'),
             :name => controller_display_name,
             :ajax_load => true,
             :ajax_scroll=>items_providers_path(),
             :initial_action => :products_repos,
             :search_class => Provider,
             :enable_create => Provider.creatable?(current_organization)}
  end

  def controller_display_name
    return 'provider'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

=begin
  def find_subscriptions
    @provider = current_organization.redhat_provider
    cp_pools = Candlepin::Owner.pools current_organization.cp_key
    subscriptions = Pool.index_pools cp_pools

    @grouped_subscriptions = []
    subscriptions.each do |sub|
      # Derived pools are not displayed here
      if sub.pool_derived
        next
      end

      # Only Red Hat provider subscriptions are shown
      p = Product.where(:cp_id => sub.product_id).first
      if p && p.provider_id == @provider.id
        @grouped_subscriptions << sub
      end
      #Product.where(:cp_id => sub.product_id).each { |product|
      #  if product && product.provider_id == @provider.id
      #    @grouped_subscriptions << sub
      #  end
      #}
    end

    @grouped_subscriptions
  end

  def setup_subs
    # TODO: See subscriptions_controller#reformat_subscriptions for a better(?) OpenStruct implementation

    @provider = current_organization.redhat_provider
    all_subs = Resources::Candlepin::Owner.pools @provider.organization.cp_key
    # We default to none imported until we can properly poll Candlepin for status of the import
    @grouped_subscriptions = {}
    all_subs.each do |sub|
      # Subscriptions with the same 'stack_id' attribute are grouped together. Not all have this
      # attribute so the 'id' is used as a default since it will be unique between
      # subscriptions.
      #
      group_id = sub['id']
      sub['productAttributes'].each do |attr|
        if attr['name'] == 'stacking_id'
          group_id = attr['value']
        elsif attr['name'] == 'support_level'
          sub['support_level'] = attr['value']
        elsif attr['name'] == 'arch'
          sub['arch'] = attr['value']
        end
      end

      # Other interesting attributes
      derived = false
      sub['machine_type'] = ''
      sub['attributes'].each do |attr|
        if attr['name'] == 'virt_only'
          if attr['value'] == 'true'
            sub['machine_type'] = _('Virtual')
          elsif attr['value'] == 'false'
            sub['machine_type'] = _('Physical')
          end
        elsif attr['name'] == 'pool_derived'
          if attr['value'] == 'true'
            sub['derived'] = true
          end
        end
      end

      # Derived pools are not displayed on the providers page
      if sub['derived'] == true
        next
      end

      Product.where(:cp_id => sub['productId']).each do |product|
        if product and product.provider == @provider
          @grouped_subscriptions[group_id] ||= []
          @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
        end
      end
x=begin TODO: Should the bundled products be displayed too?
      if sub['providedProducts'].length > 0
        sub['providedProducts'].each do |cp_product|
          product = Product.where(:cp_id => cp_product['productId']).first
          if product and product.provider == @provider
            @grouped_subscriptions[group_id] ||= []
            @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
          end
        end
      else
        product = Product.where(:cp_id => sub['productId']).first
        if product and product.provider == @provider
          @grouped_subscriptions[group_id] ||= []
          @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
        end
      end
x=end
    end
  end
=end
end
