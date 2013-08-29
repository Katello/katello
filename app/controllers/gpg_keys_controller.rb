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

  def param_rules
    {
      :create => {:gpg_key => [:name, :content, :content_upload]},
      :update => {:gpg_key => [:name, :content, :content_upload]}
    }
  end

  def items
    render_panel_direct(GpgKey, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
                        {:default_field => :name,
                         :filter=>{:organization_id=>[current_organization.id]}}
                       )
  end

  def show
    render :partial=>"common/list_update", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name']}
  end

  def new
    render :partial => "new"
  end

  def edit
    render :partial => "edit", :locals => {:editable => @gpg_key.manageable?,
                                           :name => controller_display_name}
  end

  def products_repos
    products = @gpg_key.products

    products_repos = Hash.new { |h, k| h[k] = [] }
    @gpg_key.repositories.
        in_environment(@gpg_key.organization.library).
        order('products.name ASC').
        each { |repo| products_repos[repo.product.name] << repo }

    render :partial => "products_repos",
           :locals => {:products => products, :products_repos => products_repos}
  end

  # TODO: break up this method
  # rubocop:disable MethodLength
  def create
    gpg_key_params = params[:gpg_key]
    return render_bad_parameters if gpg_key_params.nil?
    file_uploaded = gpg_key_params.has_key?("content_upload") && !gpg_key_params.has_key?("content")

    if file_uploaded
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end

    @gpg_key = GpgKey.create!( gpg_key_params.merge({:organization => current_organization}) )

    notify.success _("GPG Key '%s' was created.") % @gpg_key['name'], :asynchronous => file_uploaded

    if search_validate(GpgKey, @gpg_key.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@gpg_key, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @gpg_key["name"]
      render :json => {:no_match => true}
    end
  rescue ActiveRecord::RecordInvalid => error
    # this is needed because of the upload file though iframe
    # (we need to send json although the request says it wants HTML)
    if !request.xhr?
      render :json => {:validation_errors => error.record.errors.full_messages.to_a}, :status => :bad_request
    else
      # otherwise we use the default error handing in ApplicationController
      raise error
    end
  end

  def update
    gpg_key_params = params[:gpg_key]

    file_uploaded = gpg_key_params.has_key?("content_upload") && !gpg_key_params.has_key?("content")
    if file_uploaded
      gpg_key_params['content'] = params[:gpg_key][:content_upload].read
      gpg_key_params.delete('content_upload')
    end

    @gpg_key.update_attributes!(gpg_key_params)

    notify.success _("GPG Key '%s' was updated.") % @gpg_key["name"], :asynchronous => file_uploaded

    if !search_validate(GpgKey, @gpg_key.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @gpg_key["name"], :asynchronous => false
    end

    render :text => escape_html(gpg_key_params.values.first)
  rescue ActiveRecord::RecordInvalid => error
    # this is needed because of the upload file though iframe
    # (we need to send json although the request says it wants HTML)
    if !request.xhr?
      render :json => {:validation_errors => error.record.errors.full_messages.to_a}, :status => :bad_request
    else
      # otherwise we use the default error handing in ApplicationController
      raise error
    end
  end

  def destroy
    if @gpg_key.destroy
      notify.success _("GPG Key '%s' was deleted.") % @gpg_key[:name]
      render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
    end
  end

  protected

  def find_gpg_key
    @gpg_key = GpgKey.find(params[:id])
  end

  def panel_options
    @panel_options = {
      :title => _('GPG Keys'),
      :col => ['name'],
      :titles => [_('Name')],
      :create => _('GPG Key'),
      :create_label => _('+ New GPG Key'),
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_gpg_keys_path,
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
