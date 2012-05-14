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

class EnvironmentsController < ApplicationController
  respond_to :html, :js
  require 'rubygems'
  require 'active_support/json'

  before_filter :find_organization, :only => [:show, :edit, :update, :destroy, :index, :new, :create, :system_templates, :products]
  before_filter :authorize
  before_filter :find_environment, :only => [:show, :edit, :update, :destroy, :system_templates, :products]

  around_filter :catch_exceptions

  def section_id
    'orgs'
  end

  def rules
    manage_rule = lambda{@organization.environments_manageable?}
    view_rule = lambda{@organization.readable?}
    view_akey_rule = lambda{ActivationKey.readable?(current_organization)}
    {
      :new => manage_rule,
      :edit => view_rule,
      :create => manage_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :system_templates => view_akey_rule,
      :products => view_akey_rule
    }
  end

  def param_rules
    {
      :create => [:name, :description, :organization_id, :org_id, :prior],
      :update => {:kt_environment  => [:name, :description, :prior]}
    }
  end


  # GET /environments/new
  def new
    @environment = KTEnvironment.new(:organization => @organization)
    setup_new_edit_screen
    render :partial=>"new", :layout => "tupane_layout"
  end


  # GET /environments/1/edit
  def edit
    # Create a hash of the available environments and convert to json to be included
    # the edit view
    prior_envs = envs_no_successors - [@environment] - @environment.path
    env_labels = Hash[ *prior_envs.collect { |p| [ p.id, p.display_name ] }.flatten]
    #env_labels[''] = _("Library")
    @env_labels_json = ActiveSupport::JSON.encode(env_labels)

    @selected = @environment.prior.nil? ? env_labels[""] : env_labels[@environment.prior.id]
    render :partial=>"edit", :layout => "tupane_layout", :locals=>{:editable=> @organization.environments_manageable?}
  end

  # POST /environments
  def create
    env_params = {:name => params[:name],
              :description => params[:description],
              :prior => params[:prior],
              :organization_id => @organization.id}
    @environment =  KTEnvironment.new env_params

    @environment.save!
    notice _("Environment '%s' was created.") % @environment.name
    #this render just means return a 200 success
    render :nothing => true

  end

  # PUT /environments/1
  def update
    priorUpdated = !params[:kt_environment][:prior].nil?

    unless params[:kt_environment][:description].nil?
      params[:kt_environment][:description] = params[:kt_environment][:description].gsub("\n",'')
    end

    @environment.update_attributes(params[:kt_environment])
    @environment.save!

    if priorUpdated
      result = @environment.prior.nil? ? _("Library") : @environment.prior.name
    else
      result = params[:kt_environment].values.first
    end

    notice _("Environment '%s' was updated.") % @environment.name

    render :text =>escape_html(result)
  end

  # DELETE /environments/1
  def destroy
    @environment.destroy
    notice _("Environment '%s' was deleted.") % @environment.name
    render :partial => "common/post_delete_close_subpanel", :locals => {:path=>edit_organization_path(@organization.cp_key)}
  end

  # GET /environments/1/system_templates
  def system_templates
    render :json => @environment.system_templates
  end

  # GET /environments/1/products
  def products
    respond_to do |format|
      format.html {render :partial => "products", :content_type => 'text/html'}
      format.json {render :json => @environment.products}
    end
  end

  protected

  def find_organization
    org_id = params[:organization_id] || params[:org_id]
    @organization = Organization.first(:conditions => {:cp_key => org_id})
    notice _("Couldn't find organization '%d'") % org_id, {:level => :error} if @organization.nil?
  end

  def find_environment
    begin
      env_id = (params[:id].blank? ? nil : params[:id]) || params[:env_id]
      @environment = KTEnvironment.find env_id
    rescue Exception => error
      notice _("Couldn't find environment with ID=%d" % env_id, {:level => :error})
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def setup_new_edit_screen
    @env_labels = (envs_no_successors - [@environment]).collect {|p| [ p.display_name, p.id ]}
    @selected = @environment.prior.nil? ? "" : @environment.prior.id
  end
  
  def envs_no_successors
    envs = [@organization.library]
    envs += @organization.environments.reject {|item| !item.successor.nil?}
    envs
  end

end
