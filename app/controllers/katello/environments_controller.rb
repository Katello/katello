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

module Katello
class EnvironmentsController < Katello::ApplicationController
  respond_to :html, :js

  before_filter :find_organization, :only => [:show, :edit, :update, :destroy, :new, :create, :default_label, :products]
  before_filter :authorize
  before_filter :find_environment, :only => [:show, :edit, :update, :destroy, :products, :content_views]
  skip_before_filter :require_org

  def section_id
    'orgs'
  end

  def rules
    index_rule = lambda{Organization.any_readable?}
    manage_rule = lambda{@organization.environments_manageable?}
    view_rule = lambda{@organization.readable?}
    view_akey_rule = lambda{ActivationKey.readable?(current_organization)}
    {
      :index => index_rule,
      :all => index_rule,
      :new => manage_rule,
      :edit => view_rule,
      :create => manage_rule,
      :default_label => manage_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :products => view_akey_rule,
      :content_views => view_akey_rule,
      :registerable_paths => lambda{ true }
    }
  end

  def param_rules
    {
      :create => {:kt_environment => [:name, :label, :description, :prior]},
      :update => {:kt_environment  => [:name, :description, :prior]}
    }
  end

  def index
    render 'bastion/layouts/application', :layout => false
  end

  def all
    redirect_to action: 'index', :anchor => '/environments'
  end

  # GET /environments/new
  def new
    @environment = KTEnvironment.new(:organization => @organization)
    setup_new_edit_screen
    render :partial => "new"
  end

  # GET /environments/1/edit
  def edit
    # Create a hash of the available environments and convert to json to be included
    # the edit view
    prior_envs = envs_no_successors - [@environment] - @environment.path
    env_labels = Hash[*prior_envs.collect { |p| [p.id, p.display_name] }.flatten]
    @env_labels_json = ActiveSupport::JSON.encode(env_labels)

    @selected = @environment.prior.nil? ? env_labels[""] : env_labels[@environment.prior.id]
    render :partial => "edit", :locals => {:editable => @organization.environments_manageable?}
  end

  # POST /environments
  def create
    env_params = {:name => params[:kt_environment][:name],
                  :description => params[:kt_environment][:description],
                  :prior => params[:kt_environment][:prior],
                  :label => params[:kt_environment][:label],
                  :organization_id => @organization.id}

    env_params[:label], label_assigned = generate_label(env_params[:name], 'environment') if env_params[:label].blank?

    @environment = KTEnvironment.new env_params
    @environment.save!

    notify.success _("Environment '%s' was created.") % @environment.name
    notify.message label_assigned unless label_assigned.blank?

    #this render just means return a 200 success
    render :nothing => true
  end

  # PUT /environments/1
  def update
    prior_updated = !params[:kt_environment][:prior].nil?

    unless params[:kt_environment][:description].nil?
      params[:kt_environment][:description] = params[:kt_environment][:description].gsub("\n", '')
    end

    @environment.update_attributes(params[:kt_environment])
    @environment.save!

    if prior_updated
      result = @environment.prior.nil? ? "Library" : @environment.prior.name
    else
      result = params[:kt_environment].values.first
    end

    notify.success _("Environment '%s' was updated.") % @environment.name

    render :text => escape_html(result)
  end

  # DELETE /environments/1
  def destroy
    @environment.destroy
    if @environment.destroyed?
      notify.success _("Environment '%s' was deleted.") % @environment.name
      render :partial => "katello/common/post_delete_close_subpanel",
             :locals => { :path => edit_organization_path(@organization.label) }
    else
      err_msg = N_("Removal of the environment failed. If you continue having trouble with this, please contact an Administrator.")
      notify.error err_msg
      render :nothing => true
    end
  end

  # GET /environments/1/products
  def products
    @products = if params[:content_view_id]
                  view = ContentView.find(params[:content_view_id])
                  view.try(:products, @environment) || []
                else
                  @environment.library? ? current_organization.products : @environment.products
                end

    respond_to do |format|
      format.html {render :partial => "products", :locals => {:products => @products}, :content_type => 'text/html'}
      format.json {render :json => @products}
    end
  end

  # GET /environments/1/content_views
  def content_views
    content_views = if params[:include_default]
                      @environment.content_views.readable(current_organization)
                    else
                      ContentView.readable(current_organization).in_environment(@environment)
                    end
    respond_to do |format|
      format.json {render :json => content_views}
    end
  end

  # GET /environments/registerable_paths
  def registerable_paths
    paths = environment_paths(library_path_element("systems_readable?"),
                              environment_path_element("systems_readable?"))
    respond_to do |format|
      format.json { render :json => paths }
    end
  end

  protected

  def find_organization
    org_id = params[:organization_id] || params[:org_id]
    @organization = Organization.first(:conditions => {:label => org_id})
    notify.error _("Couldn't find organization '%s'") % org_id if @organization.nil?
  end

  def find_environment
    @environment = KTEnvironment.find(params[:id] || params[:env_id])
  end

  def setup_new_edit_screen
    @env_labels = (envs_no_successors - [@environment]).collect {|p| [p.display_name, p.id]}
    @selected = @environment.prior.nil? ? "" : @environment.prior.id
  end

  def envs_no_successors
    envs = [@organization.library]
    envs += @organization.environments.reject {|item| !item.successor.nil?}
    envs
  end

end
end
