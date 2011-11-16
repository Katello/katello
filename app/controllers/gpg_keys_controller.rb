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

class GpgKeysController < ApplicationController
  include AutoCompleteSearch

  before_filter :require_user
  before_filter :find_gpg_key, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize
  before_filter :panel_options, :only => [:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    read_test = lambda{true}#lambda{GpgKey.readable?(current_organization)}
    manage_test = lambda{true}#lambda{GpgKey.manageable?(current_organization)}
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,
      :auto_complete_search => read_test,

      :new => manage_test,
      :create => manage_test,

      :edit => read_test,
      :update => manage_test,

      :destroy => manage_test
    }
  end

  def items
    render_panel_items(GpgKey.where(:organization_id => current_organization), @panel_options, params[:search], params[:offset])
  end

  def show
    render :partial=>"common/list_update", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name']}
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:editable => true,#GpgKey.manageable?(current_organization),
                                                                       :name => controller_display_name }
  end

  def create
    @gpg_key = GpgKey.create!( params[:gpg_key].merge({ :organization => current_organization }) )

    notice _("GPG Key '#{@gpg_key['name']}' was created.")
    
    if GpgKey.where(:id => @gpg_key.id).search_for(params[:search]).include?(@gpg_key)
      render :partial=>"common/list_item", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notice _("'#{@gpg_key["name"]}' did not meet the current search criteria and is not being shown."), { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    end
  rescue Exception => error
    Rails.logger.error error.to_s
    errors error
    render :text => error, :status => :bad_request
  end

=begin
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

      if not ActivationKey.where(:id => @activation_key.id).search_for(params[:search]).include?(@activation_key)
        notice _("'#{@activation_key["name"]}' no longer matches the current search criteria."), { :level => :message, :synchronous_request => true }
      end

      render :text => escape_html(result)

    rescue Exception => error
      errors error

      respond_to do |format|
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end
=end
  def destroy
    begin
      @gpg_key.destroy
      if @gpg_key.destroyed?
        notice _("GPG Key '#{@gpg_key[:name]}' was deleted.")
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      else
        raise
      end
    rescue Exception => e
      errors e
    end
  end

  protected

  def find_gpg_key
    begin
      @gpg_key = GpgKey.find(params[:id])
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
      :title => _('GPG Keys'),
      :col => ['name'],
      :create => _('GPG Key'), 
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_gpg_keys_path(),
      :enable_create => true#GpgKey.manageable?(current_organization)
    }
  end

  private
 
  def controller_display_name
    return _('gpg_key')
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
