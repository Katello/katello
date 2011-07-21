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

  before_filter :require_user
  before_filter :find_activation_key, :only => [:show, :edit, :update, :destroy, :subscriptions, :update_subscriptions]
  before_filter :panel_options, :only => [:index, :items]

  respond_to :html, :js

  def section_id
    'systems'
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
    consumed = []
    debugger
    subscriptions = reformat_subscriptions(Candlepin::Owner.pools current_organization.cp_key)
    subscriptions.sort! {|a,b| a.sub <=> b.sub}
    render :partial=>"subscriptions", :locals=>{:akey=>@activation_key, :all_subs => subscriptions, :consumed => consumed}
  end

  def update_subscriptions
    subs = params[:activation_key][:consumed_sub_ids]
    debugger
    if subs and @activation_key
      @activation_key.subscriptions = subs.collect { |s| KTSubscription.create!(:subscription => s) } 
      notice _("Activation Key subscriptions updated.")
      render :nothing =>true
    else
      errors "Unable to update subscriptions."
      render :nothing =>true
    end
  end

  def new
    activation_key = ActivationKey.new
    render :partial => "new", :locals => {:activation_key => activation_key}
  end

  def edit
    render :partial => "edit", :locals => {:activation_key => @activation_key}
  end

  def create
    begin
      @activation_key = ActivationKey.create!(:name => params[:activation_key_name], :description => params[:activation_key_description], :organization_id => current_organization)
      notice _("Activation key '#{@activation_key['name']}' was created.")
      render :partial=>"common/list_item", :locals=>{:item=>@activation_key, :accessor=>"id", :columns=>['name']}

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

      @activation_key.update_attributes!(params[:activation_key])
      notice _("Activation key '#{@activation_key["name"]}' was updated.")

      respond_to do |format|
        format.html { render :text => escape_html(result) }
        format.js
      end
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
        render :partial => "common/list_remove", :locals => {:id => params[:id]}
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
      :name => _('key'),
      :ajax_scroll => items_activation_keys_path()}
  end

  private

  require 'ostruct'

  def reformat_subscriptions(all_subs)
    subscriptions = []
    all_subs.each do |s|
      cp = OpenStruct.new
      cp.sub = s["subscriptionId"]
      cp.name = s["productName"]
      subscriptions << cp if !subscriptions.include? cp 
    end
    subscriptions
  end
end
