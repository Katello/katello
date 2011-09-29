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

class ActivationKeysController < ApplicationController
  include AutoCompleteSearch
  include ActivationKeysHelper

  before_filter :require_user
  before_filter :find_activation_key, :only => [:show, :edit, :edit_environment, :update, :destroy, :subscriptions, :update_subscriptions]
  before_filter :authorize #after find_activation_key, since the key is required for authorization
  before_filter :panel_options, :only => [:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'systems'
  end

  def rules
    read_test = lambda{ActivationKey.readable?(current_organization)}
    manage_test = lambda{ActivationKey.manageable?(current_organization)}
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,
      :auto_complete_search => read_test,

      :new => manage_test,
      :create => manage_test,

      :edit => read_test,
      :edit_environment => read_test,
      :update => manage_test,

      :subscriptions => read_test,
      :update_subscriptions => manage_test,

      :destroy => manage_test
    }
  end

  def index
    begin
      @activation_keys = ActivationKey.search_for(params[:search]).where(:organization_id => current_organization).limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @activation_keys = ActivationKey.search_for('')
      render :index, :status => :bad_request and return
    end
  end

  def items
    start = params[:offset]
    @activation_keys = ActivationKey.search_for(params[:search]).where(:organization_id => current_organization).limit(current_user.page_size).offset(start)
    render_panel_items @activation_keys, @panel_options
  end

  def show
    render :partial=>"common/list_update", :locals=>{:item=>@activation_key, :accessor=>"id", :columns=>['name']}
  end

  def subscriptions
    consumed = @activation_key.pools
    subscriptions = reformat_subscriptions(Candlepin::Owner.pools current_organization.cp_key)
    subscriptions.sort! {|a,b| a.name <=> b.name}
    for sub in subscriptions
      sub.allocated = 0
      for consume in consumed
        if consume.subscription == sub.sub
          sub.allocated = consume.key_pools[0].allocated
        end
      end
    end
    render :partial=>"subscriptions", :layout => "tupane_layout", :locals=>{:akey=>@activation_key, :subscriptions => subscriptions,
                                                                            :consumed => consumed, :editable=>ActivationKey.manageable?(current_organization)}
  end

  def update_subscriptions
    pool = KTPool.where(:cp_id => params[:subscription_id])[0]
    allocated = params[:activation_key][:allocated]

    if pool.nil? and @activation_key and allocated != "0"
      KTPool.create!(:cp_id => params[:subscription_id], :key_pools => [KeyPool.create!(:allocated=> allocated, :activation_key => @activation_key)])
      notice _("Activation Key subscriptions updated.")
      render :text => escape_html(allocated)
    elsif pool and @activation_key
      key_sub = KeyPool.where(:activation_key_id => @activation_key.id, :pool_id => pool.id)[0]

      if key_sub
        if allocated != "0"
          key_sub.allocated = allocated
          key_sub.save!
        else
          key_sub.destroy
        end
      else
        KeyPool.create!(:activation_key_id => @activation_key.id, :pool_id => pool.id, :allocated => allocated)
      end
      render :text => escape_html(allocated)
      notice _("Activation Key subscriptions updated.")
    else
      if allocated != "0"
        errors _("Unable to update subscriptions.")
      end
      render :text => escape_html(allocated)
    end
  end

  def new
    activation_key = ActivationKey.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:activation_key => activation_key}
  end

  def edit
    # Create a hash of the system templates associated with the currently assigned default environment and
    # convert to json for use in the edit view
    templates = Hash[ *@activation_key.environment.system_templates.collect { |p| [p.id, p.name] }.flatten]
    templates[''] = no_template
    @system_templates_json = ActiveSupport::JSON.encode(templates)
    @system_template = SystemTemplate.find(@activation_key.system_template_id) unless @activation_key.system_template_id.nil?
    render :partial => "edit", :layout => "tupane_layout", :locals => {:activation_key => @activation_key,
                                                                       :editable=>ActivationKey.manageable?(current_organization),
                                                                       :name=>controller_display_name}
  end

  def edit_environment
    render :partial => "edit_environment"
  end

  def create
    begin
      @activation_key = ActivationKey.create!(params[:activation_key]) do |key|
        key.organization = current_organization
        key.user = current_user
      end
      notice _("Activation key '#{@activation_key['name']}' was created.")
      render :partial=>"common/list_item", :locals=>{:item=>@activation_key, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}

    rescue Exception => error
      Rails.logger.error error.to_s
      errors error
      render :text => error, :status => :bad_request
    end
  end

  def update
    result = params[:activation_key].nil? ? "" : params[:activation_key].values.first

    begin
      unless params[:activation_key][:description].nil?
        result = params[:activation_key][:description] = params[:activation_key][:description].gsub("\n",'')
      end

      if !params[:activation_key][:system_template_id].nil? and params[:activation_key][:system_template_id].blank?
        params[:activation_key][:system_template_id] = nil
      end

      @activation_key.update_attributes!(params[:activation_key])

      notice _("Activation key '#{@activation_key["name"]}' was updated.")

      unless params[:activation_key][:system_template_id].nil? or params[:activation_key][:system_template_id].blank?
        # template is being updated.. so return template name vs id...
        system_template = SystemTemplate.find(@activation_key.system_template_id)
        result = system_template.name
      end

      render :text => escape_html(result)

    rescue Exception => error
      errors error

      respond_to do |format|
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def destroy
    begin
      @activation_key.destroy
      if @activation_key.destroyed?
        notice _("Activation key '#{@activation_key[:name]}' was deleted.")
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      else
        raise
      end
    rescue Exception => e
      errors e.to_s
    end
  end

  protected

  def find_activation_key
    begin
      @activation_key = ActivationKey.find(params[:id])
    rescue Exception => error
      errors error.to_s

      # flash_to_headers is an after_filter executed on the application controller;
      # however, a render from within a before_filter will halt the filter chain.
      # as a result, we are explicitly executing it here.
      flash_to_headers

      render :text => error, :status => :bad_request
    end
  end

  def panel_options
    @panel_options = { 
      :title => _('Activation Keys'),
      :col => ['name'],
      :create => _('Key'), 
      :name => controller_display_name,
      :ajax_scroll => items_activation_keys_path(),
      :enable_create => ActivationKey.manageable?(current_organization)}
  end

  private

  require 'ostruct'

  def reformat_subscriptions(all_subs)
    subscriptions = []
    all_subs.each do |s|
      cp = OpenStruct.new
      cp.sub = s["id"]
      cp.name = s["productName"]
      cp.available = s["quantity"]
      subscriptions << cp if !subscriptions.include? cp 
    end
    subscriptions
  end
  
  def controller_display_name
    return _('activation_key')
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
