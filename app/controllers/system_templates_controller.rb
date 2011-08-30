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

class SystemTemplatesController < ApplicationController
  include AutoCompleteSearch

  before_filter :setup_options, :only => [:index, :items]
  before_filter :find_template, :only =>[:update, :edit, :destroy, :show]

  around_filter :catch_exceptions

  def section_id
    'systems'
  end


  def rules
    #read_test = lambda{Provider.any_readable?(current_organization)}
    #manage_test = lambda{current_organization.syncable?}
    read_test = lambda{true}
    manage_test = lambda{true}
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,
      :edit => read_test,
      :update => manage_test,
      :destroy => manage_test,
      :new => manage_test,
      :create => manage_test,
    }
  end


  def index
    @templates = SystemTemplate.search_for(params[:search]).where(:environment_id => current_organization.locker.id).limit(current_user.page_size)
    retain_search_history
  end
  
  def items
    start = params[:offset]
    @templates = SystemTemplate.readable(current_organization).search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @templates, @panel_options
  end
  
  def setup_options
    columns = ['name']
    @panel_options = { :title => _('System Templates'),
                 :col => columns,
                 :create => _('Template'),
                 :name => _('template'),
                 :ajax_scroll => items_system_templates_path(),
                 :enable_create => SystemTemplate.creatable?(current_organization) }
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout",
           :locals => {:template=>@template, :editable=> @template.editable? }
  end

  def update
    attrs = params[:system_template]
    if attrs[:name]
      result = @template.name = attrs[:name]
    elsif attrs[:description]
      result = @template.description = attrs[:description]

    end
    @template.save!
    notice _("Template #{@template.name} updated successfully.")
    render :text=>result

  rescue Exception => e
    errors e
    render :text=>e, :status=>:bad_request
  end

  def destroy
      
      @template.destroy
      notice _("Template '#{@template.name}' was deleted.")
      render :partial => "common/list_remove", :locals => {:id => @template.id}
  rescue Exception => e
      errors e.to_s
      render :text=> e, :status=>:bad_request
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@template, :accessor=>"id", :columns=>['name']}
  end

  def new
    @template = SystemTemplate.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:template => @template}
  end

  def create
    
    obj_params = params[:system_template]
    obj_params[:environment_id] = current_organization.locker

    @template = SystemTemplate.create!(obj_params)
    notice _("Sync Plan '#{@template.name}' was created.")
    render :partial=>"common/list_item", :locals=>{:item=>@template, :accessor=>"id", :columns=>['name']}
  rescue Exception => e
    errors e
    render :text => e, :status => :bad_request
  end
  
  protected

  def find_template
    @template = SystemTemplate.find(params[:id])
    raise _("Cannot modify a template that is another environment") if !@template.environment.locker?
  rescue Exception => e
    errors e
    render :text=>e, :status=>400 and return false
  end

end
