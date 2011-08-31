
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
  skip_before_filter :authorize
  before_filter :find_organization, :only => [:edit, :update, :destroy]
  before_filter :authorize #call authorize after find_organization so we call auth based on the id instead of cp_id
  before_filter :setup_options, :only=>[:index, :items]

  def rules
    index_test = lambda{Organization.any_readable?}
    create_test = lambda{Organization.creatable?}
    read_test = lambda{@organization.readable?}
    edit_test = lambda{@organization.editable?}
    delete_test = lambda{@organization.deletable?}

    {:index =>  index_test,
      :items => index_test,
      :new => create_test,
      :create => create_test,
      :edit => read_test,
      :update => edit_test,
      :destroy => delete_test,
    }
  end


  def section_id
    'orgs'
  end

  def index
    begin
      @organizations = Organization.readable.search_for(params[:search]).limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @organizations = Organization.search_for ''
      render :index, :status => :bad_request and return
    end
  end

  def items
    start = params[:offset]
    @organizations = Organization.readable.search_for(params[:search]).limit(current_user.page_size).offset(start)
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
    rescue Exception => error
      errors error
      print "\n\n\n\n", error.to_s
      Rails.logger.info error.backtrace.join("\n")
      render :text=> error.to_s, :status=>:bad_request and return
    end
    render :partial=>"common/list_item", :locals=>{:item=>@organization, :accessor=>"cp_key", :columns=>['name'], :name=>controller_name}
  end

  def edit
    @env_choices =  @organization.environments.collect {|p| [ p.name, p.name ]}
    render :partial=>"edit", :layout => "layouts/tupane_layout", :locals=>{:editable=>@organization.editable?}
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
      render :partial => "common/list_remove", :locals => {:id=> id, :name=> controller_name}
    else
      errors [_("Could not delete organization '#{params[:id]}'."),  _("At least one organization must exist.")]
      
      render :text => "At least one organization must exist.", :status=>:bad_request and return
    end
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

  def setup_options
    @panel_options = { :title => _('Organizations'),
               :col => ['name'],
               :create => _('Organization'),
               :name => controller_name,
               :accessor => :cp_key,
               :ajax_scroll => items_organizations_path(),
               :enable_create => Organization.creatable?}
  end

  def controller_name
    return _('organization')
  end

end
