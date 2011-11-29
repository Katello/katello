
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

class OrganizationsController < ApplicationController
  include AutoCompleteSearch
  respond_to :html, :js
  skip_before_filter :authorize
  before_filter :find_organization, :only => [:edit, :update, :destroy, :events]
  before_filter :find_organization_by_id, :only => [:environments_partial]
  before_filter :authorize #call authorize after find_organization so we call auth based on the id instead of cp_id
  before_filter :setup_options, :only=>[:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  def rules
    index_test = lambda{Organization.any_readable?}
    create_test = lambda{Organization.creatable?}
    read_test = lambda{@organization.readable?}
    edit_test = lambda{@organization.editable?}
    delete_test = lambda{@organization.deletable?}

    {:index =>  index_test,
      :items => index_test,
      :auto_complete_search => index_test,
      :new => create_test,
      :create => create_test,
      :edit => read_test,
      :update => edit_test,
      :destroy => delete_test,
      :environments_partial => index_test,
      :events => read_test
    }
  end

  def section_id
    'orgs'
  end

  def items
    render_panel_items(Organization.readable.order('lower(organizations.name)'), @panel_options, params[:search], params[:offset])
  end

  def new
    render :partial=>"new", :layout => "tupane_layout"
  end

  def create
    begin
      if params[:envname] && params[:envname] != ''
        @new_env = KTEnvironment.new(:name => params[:envname], :description => params[:envdescription])
      else
        @new_env = nil
      end

      @organization = Organization.new(:name => params[:name], :description => params[:description], :cp_key => params[:name].tr(' ', '_'))
      @organization.save!
      
      if @new_env
        @new_env.organization = @organization
        @new_env.prior = @organization.locker
        @new_env.save!
      end
      notice [_("Organization '#{@organization["name"]}' was created.")]
    rescue Exception => error
      errors(error, {:include_class_name => KTEnvironment::ERROR_CLASS_NAME})
      Rails.logger.info error.backtrace.join("\n")
      #rollback creation of the org if the org creation passed but the environment was not created
      if @organization && @organization.id #it is saved to the db
        @organization.destroy
      end

      render :text=> error.to_s, :status=>:bad_request and return
    end
    
    if Organization.where(:id => @organization.id).search_for(params[:search]).include?(@organization)
      notice [_("Organization '#{@organization["name"]}' was created."), _("Click on 'Add Environment' to create the first environment")]
      render :partial=>"common/list_item", :locals=>{:item=>@organization, :accessor=>"cp_key", :columns=>['name'], :name=>controller_display_name}
    else
      notice _("Organization '#{@organization["name"]}' was created.")
      notice _("'#{@organization["name"]}' did not meet the current search criteria and is not being shown."), { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    end
  end

  def edit
    @env_choices =  @organization.environments.collect {|p| [ p.name, p.name ]}
    render :partial=>"edit", :layout => "tupane_layout", :locals=>{:organization=>@organization, :editable=>@organization.editable?, :name => controller_display_name}
  end

  def update
    result = ""
    begin
      unless params[:organization][:description].nil?
        result = params[:organization][:description] = params[:organization][:description].gsub("\n",'')
      end

      @organization.update_attributes!(params[:organization])
      notice _("Organization '#{@organization["name"]}' was updated.")
      
      if not Organization.where(:id => @organization.id).search_for(params[:search]).include?(@organization)
        notice _("'#{@organization["name"]}' no longer matches the current search criteria."), { :level => :message, :synchronous_request => true }
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
    if current_organization == @organization
      errors [_("Could not delete organization '#{params[:id]}'."),  _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]

      render :text => "The current organization cannot be deleted. Please switch to a different organization before deleting.", :status => :bad_request and return
    elsif Organization.count > 1
      id = @organization.cp_key
      @name = @organization.name
      begin
        @organization.destroy
        notice _("Organization '#{params[:id]}' was deleted.")
      rescue Exception => error
        errors error.to_s
        render :text=> error.to_s, :status=>:bad_request and return
      end
      render :partial => "common/list_remove", :locals => {:id=> id, :name=> controller_display_name}
    else
      errors [_("Could not delete organization '#{params[:id]}'."),  _("At least one organization must exist.")]

      render :text => "At least one organization must exist.", :status=>:bad_request and return
    end
  end

  def environments_partial
    @organization = Organization.find(params[:id])
    accessible_envs = KTEnvironment.systems_registerable(@organization)
    setup_environment_selector(@organization, accessible_envs)
    @environment = first_env_in_path(accessible_envs, false, @organization)
    render :partial=>"environments", :locals=>{:accessible_envs => accessible_envs}
  end

  def events
    render :partial => 'events', :layout => "tupane_layout"
  end

  protected

  def find_organization
    begin
      @organization = Organization.first(:conditions => {:cp_key => params[:id]})
      raise if @organization.nil?
    rescue Exception => error
      errors _("Couldn't find organization with ID=#{params[:id]}")
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_organization_by_id
    begin
      @organization = Organization.find(params[:id])
      raise if @organization.nil?
    rescue Exception => error
      errors _("Couldn't find organization with ID=#{params[:id]}")
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def setup_options
    @panel_options = { :title => _('Organizations'),
               :col => ['name'],
               :create => _('Organization'),
               :name => controller_display_name,
               :accessor => :cp_key,
               :ajax_load  => true,
               :ajax_scroll => items_organizations_path(),
               :enable_create => Organization.creatable?}
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def controller_display_name
    return _('organization')
  end

end
