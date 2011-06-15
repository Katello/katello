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

  before_filter :find_organization, :only => [:show, :edit, :update, :destroy, :index, :new, :create]
  before_filter :find_environment, :only => [:show, :edit, :update, :destroy]
  around_filter :catch_exceptions

  def section_id
    'orgs'
  end

  # GET /environments/new
  def new
    @environment = KPEnvironment.new(:organization => @organization)
    setup_new_edit_screen
    render :partial=>"new"
  end

  # GET /environments/1/edit
  def edit
    # Create a hash of the available environments and convert to json to be included
    # the edit view
    prior_envs = envs_no_successors - [@environment] - @environment.path
    env_labels = Hash[ *prior_envs.collect { |p| [ p.id, p.name ] }.flatten]
    env_labels[''] = _("Locker")
    @env_labels_json = ActiveSupport::JSON.encode(env_labels)

    @selected = @environment.prior.nil? ? env_labels[""] : env_labels[@environment.prior.id]
    render :partial=>"edit"
  end


  # POST /environments
  def create
    env_params = {:name => params[:name],
              :description => params[:description],
              :prior => params[:prior],
              :organization_id => @organization.id}
    @environment =  KPEnvironment.new env_params

    @environment.save!
    notice _("Environment '#{@environment.name}' was created.")
    render :json=>""

  end

  # PUT /environments/1
  def update
    priorUpdated = !params[:kp_environment][:prior].nil?

    unless params[:kp_environment][:description].nil?
      params[:kp_environment][:description] = params[:kp_environment][:description].gsub("\n",'')
    end

    @environment.update_attributes(params[:kp_environment])
    @environment.save!

    if priorUpdated
      result = @environment.prior.nil? ? _("Locker") : @environment.prior.name
    else
      result = params[:kp_environment].values.first;
    end

    notice _("Environment '#{@environment.name}' was updated.")

    render :text =>escape_html(result)
  end

  # DELETE /environments/1
  def destroy
    @environment.destroy
    notice _("Environment '#{@environment.name}' was deleted.")
    render :text=>""
  end

  protected

  def find_organization
    org_id = params[:organization_id] || params[:org_id]
    @organization = Organization.first(:conditions => {:cp_key => org_id})
    errors _("Couldn't find organization '#{org_id}'") if @organization.nil?
  end

  def find_environment
    env_id = (params[:id].blank? ? nil : params[:id]) || params[:env_id]
    @environment = KPEnvironment.find env_id
    notice _("Couldn't find environment '#{env_id}'") if @environment.nil?
    redirect_to :action => :index and return if @environment.nil?
  end

  def setup_new_edit_screen
    envs_no_successors = @organization.environments.reject {|item| !item.successor.nil?}
    @env_labels = (envs_no_successors - [@environment]).collect {|p| [ p.name, p.id ]}
    @selected = @environment.prior.nil? ? "" : @environment.prior.id
  end
  def envs_no_successors
    @organization.environments.reject {|item| !item.successor.nil?}
  end

  def catch_exceptions
    yield
  rescue Exception => error
    errors error
    render :text => error, :status => :bad_request
  end
end
