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

require 'pp'

class OrganizationsController < ApplicationController
  navigation :organizations
  include AutoCompleteSearch
  respond_to :html, :js

  before_filter :find_organization, :only => [:show, :edit, :update, :destroy]
  before_filter :setup_options, :only=>[:index, :items]

  def section_id
    'orgs'
  end

  def index
    begin
      @organizations = Organization.search_for(params[:search]).limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @organizations = Organization.search_for ''
      render :index, :status => :bad_request and return
    end
  end

  def items
    start = params[:offset]
    @organizations = Organization.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @organizations, @panel_options
  end


  def new
    render :partial=>"new", :layout => "tupane_layout"
  end

  def create
    begin
      @organization = Organization.new(:name => params[:name], :description => params[:description], :cp_key => params[:name].tr(' ', '_'))
      @organization.save!
      notice [_("Organization '#{@organization["name"]}' was created."), _("Click on 'Add Environment' to create the first environment")]
      # TODO: example - create permission for the organization
      #current_user.role.first.allow 'show', 'organization', "org_name:#{@organization.name}"
    rescue Exception => error 
      errors error
      print "\n\n\n\n", error.to_s
      Rails.logger.info error.backtrace.join("\n")
      render :text=> error.to_s, :status=>:bad_request and return
    end
    render :partial=>"common/list_item", :locals=>{:item=>@organization, :accessor=>"cp_key", :columns=>['name']}
  end

  def edit
    @env_choices =  @organization.environments.collect {|p| [ p.name, p.name ]}
    render :partial=>"edit", :layout => "layouts/tupane_layout"
  end

  def update
    result = ""
    begin
      unless params[:organization][:description].nil?
        result = params[:organization][:description] = params[:organization][:description].gsub("\n",'')
      end

      @organization.update_attributes!(params[:organization])
      notice _("Organization '#{@organization["name"]}' was updated.")

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
    if Organization.count > 1
      @id = @organization.id
      begin
        @organization.destroy
        notice _("Organization '#{params[:id]}' was deleted.")
      rescue Exception => error
        errors error.to_s
        render :text=> error.to_s, :status=>:bad_request and return
      end
      render :partial => "common/list_remove", :locals => {:id => @id}
    else
      errors [_("Could not delete organization '#{params[:id]}'."),  _("At least one organization must exist.")]
      
      render :text => "At least one organization must exist.", :status=>:bad_request and return
    end
  end

  protected

  def find_organization
    @organization = Organization.first(:conditions => {:cp_key => params[:id]})
    errors _("Couldn't find organization '#{params[:organization_id]}'") if @organization.nil?
    redirect_to(:controller => :organizations, :action => :index) and return if @organization.nil?
  end

  def setup_options
    @panel_options = { :title => _('Organizations'),
               :col => ['name'],
               :create => _('Organization'),
               :name => _('organization'),
               :accessor => :cp_key,
               :ajax_scroll => items_organizations_path()}
  end


end
