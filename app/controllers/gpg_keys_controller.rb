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
    create_test = lambda{current_organization && GpgKey.createable?(current_organization)}
    index_test = lambda{current_organization && GpgKey.any_readable?(current_organization)}
    {
      :index => index_test,
      :items => index_test,
      :show => read_test,
      :products_repos => read_test,
      :auto_complete_search => index_test,

      :new => create_test,
      :create => create_test,

      :edit => read_test,
      :update => manage_test,

      :destroy => manage_test
    }
  end

  def items
    render_panel_direct(GpgKey, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
      :filter=>{:organization_id=>[current_organization.id]})
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

    repos_hash = {}
    @gpg_key.repositories.each do |repo|
      repos_hash[repo.environment_product.product.name] ||= []
      repos_hash[repo.environment_product.product.name] << repo
    end
    products_repos = repos_hash.sort_by{|product, repo| product}

    render :partial => "products_repos", :layout => "tupane_layout", 
            :locals => {:products => products, :products_repos => products_repos}
  end

  def create
    gpg_key_params = params[:gpg_key]
    
    if params[:gpg_key].has_key?("content_upload") and not params[:gpg_key].has_key?("content")
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end

    @gpg_key = GpgKey.create!( gpg_key_params.merge({ :organization => current_organization }) )

    notice _("GPG Key '%s' was created.") % @gpg_key['name']

    if search_validate(GpgKey, @gpg_key.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notice _("'%s' did not meet the current search criteria and is not being shown.") % @gpg_key["name"], { :level => 'message', :synchronous_request => false }
      render :json => { :no_match => true }
    end
  rescue Exception => error
    Rails.logger.error error.to_s
    return_error = notice(error, {:level => :error})
    render :json => return_error.to_json, :status => :bad_request
  end

  def update
    gpg_key_params = params[:gpg_key]

    if params[:gpg_key].has_key?("content_upload") and not params[:gpg_key].has_key?("content")
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end

    @gpg_key.update_attributes!(gpg_key_params)

    notice _("GPG Key '%s' was updated.") % @gpg_key["name"]

    if not search_validate(GpgKey, @gpg_key.id, params[:search])
      notice _("'%s' no longer matches the current search criteria.") % @gpg_key["name"], { :level => :message, :synchronous_request => true }
    end

    render :text => escape_html(gpg_key_params.values.first)

  rescue Exception => error
    notice error, {:level => :error}

    respond_to do |format|
      format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
    end
  end

  def destroy
    begin
      @gpg_key.destroy
      if @gpg_key.destroyed?
        notice _("GPG Key '%s' was deleted.") % @gpg_key[:name]
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      else
        raise
      end
    rescue Exception => e
      notice e, {:level => :error}
    end
  end

  protected

  def find_gpg_key
    begin
      @gpg_key = GpgKey.find(params[:id])
    rescue Exception => error
      notice error.to_s, {:level => :error}

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
      :titles => [_('Name')],
      :create => _('GPG Key'), 
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_gpg_keys_path(),
      :initial_action=> :products_repos,
      :enable_create => GpgKey.createable?(current_organization),
      :search_class=>GpgKey
    }
  end

  private
 
  def controller_display_name
    return 'gpg_key'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
