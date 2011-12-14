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
  before_filter :find_gpg_key, :only => [:show, :edit, :update, :destroy, :products_repos]
  before_filter :authorize
  before_filter :panel_options, :only => [:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    read_test = lambda{@gpg_key.readable?}
    manage_test = lambda{@gpg_key.manageable?}
    create_test = lambda{GpgKey.createable?(current_organization)}
    index_test = lambda{GpgKey.any_readable?(current_organization)}
    {
      :index => index_test,
      :items => index_test,
      :show => read_test,
      :products_repos => read_test,
      :auto_complete_search => index_test,

      :new => create_test,
      :create => create_test,

      :edit => manage_test,
      :update => manage_test,

      :destroy => manage_test
    }
  end

  def items
    render_panel_items(GpgKey.readable(current_organization), @panel_options, params[:search], params[:offset])
  end

  def show
    render :partial=>"common/list_update", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name']}
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:editable => @gpg_key.manageable?,
                                                                       :name => controller_display_name }
  end

  def products_repos
    products = @gpg_key.products
    repositories = @gpg_key.repositories
    render :partial => "products_repos", :layout => "tupane_layout", 
            :locals => {:products => products, :repositories => repositories}
  end

  def create
    gpg_key_params = params[:gpg_key]
    
    if params[:gpg_key].has_key?("content_upload") and not params[:gpg_key].has_key?("content")
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end

    @gpg_key = GpgKey.create!( gpg_key_params.merge({ :organization => current_organization }) )

    notice _("GPG Key '#{@gpg_key['name']}' was created.")
    
    if GpgKey.where(:id => @gpg_key.id).search_for(params[:search]).include?(@gpg_key)
      render :partial=>"common/list_item", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notice _("'#{@gpg_key["name"]}' did not meet the current search criteria and is not being shown."), { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    end
  rescue Exception => error
    Rails.logger.error error.to_s
    return_error = errors(error)
    render :json => return_error.to_json, :status => :bad_request
  end

  def update
    gpg_key_params = params[:gpg_key]
    
    if params[:gpg_key].has_key?("content_upload") and not params[:gpg_key].has_key?("content")
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end
    
    @gpg_key.update_attributes!(gpg_key_params)

    notice _("GPG Key '#{@gpg_key["name"]}' was updated.")
    
    if not GpgKey.where(:id => @gpg_key.id).search_for(params[:search]).include?(@gpg_key)
      notice _("'#{@gpg_key["name"]}' no longer matches the current search criteria."), { :level => :message, :synchronous_request => true }
    end
    
    render :text => escape_html(gpg_key_params.values.first)

  rescue Exception => error
    errors error

    respond_to do |format|
      format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
    end
  end

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
      :initial_action=> :products_repos,
      :enable_create => GpgKey.createable?(current_organization)
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
