
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
  before_filter :find_organization, :only => [:edit, :update, :destroy, :events]
  before_filter :find_organization_by_id, :only => [:environments_partial, :download_debug_certificate]
  before_filter :authorize #call authorize after find_organization so we call auth based on the id instead of cp_id
  before_filter :setup_options, :only=>[:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  def rules
    index_test = lambda{Organization.any_readable?}
    create_test = lambda{Organization.creatable?}
    read_test = lambda{@organization.readable?}
    edit_test = lambda{@organization.editable?}
    delete_test = lambda{@organization.deletable?}

    environments_partial_test = lambda do
      if "true" == params[:new]
        Organization.creatable?
      else
        params[:user_id] &&
            ((current_user.id.to_s ==  params[:user_id].to_s) || current_user.editable?)
      end
    end

    {:index =>  index_test,
      :items => index_test,
      :auto_complete_search => index_test,
      :new => create_test,
      :create => create_test,
      :edit => read_test,
      :update => edit_test,
      :destroy => delete_test,
      :environments_partial => environments_partial_test,
      :events => read_test,
      :download_debug_certificate => edit_test
    }
  end

  def param_rules
    {
      :create =>[:name, :description, :envname, :envdescription],
      :update => {:organization  => [:description]}
    }
  end


  def section_id
    'orgs'
  end

  def items
    ids = Organization.readable.collect{|o| o.id}
    render_panel_direct(Organization, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
                        {:default_field => :name, :filter=>[{"id"=>ids}]})
  end

  def new
    render :partial=>"new", :layout => "tupane_layout"
  end

  def create
    begin
      cp_key = params[:name].tr(' ', '_')
      # org is being deleted
      if Organization.find_by_cp_key(cp_key).nil? && Organization.unscoped.find_by_cp_key(cp_key)
        msg = _("Organization '%s' already exists and either has been scheduled for deletion or failed deletion.") % params[:name]
        raise msg
      end

      if params[:envname] && params[:envname] != ''
        @new_env = KTEnvironment.new(:name => params[:envname], :description => params[:envdescription])
      else
        @new_env = nil
      end

      org_created = false
      @organization = Organization.new(:name => params[:name], :description => params[:description], :cp_key => params[:name].tr(' ', '_'))
      @organization.save!
      org_created = true

      if @new_env
        @new_env.organization = @organization
        @new_env.prior = @organization.library
        @new_env.save!
      end
      notify.success _("Organization '%s' was created.") % @organization["name"]
    rescue => error
      notify.exception error
      Rails.logger.error error.backtrace.join("\n")
      #rollback creation of the org if the org creation passed but the environment was not created
      if @organization && @organization.id #it is saved to the db
        @organization.destroy
      end

      render :text=> error.to_s, :status=>:bad_request and return
    end

    if search_validate(Organization, @organization.id, params[:search])
      notify.success _("Click on 'Add Environment' to create the first environment") if @new_env.nil?
      render :partial=>"common/list_item", :locals=>{:item=>@organization, :accessor=>"cp_key", :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @organization["name"]
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
      if params[:organization].try :[], :description
        result = params[:organization][:description] = params[:organization][:description].gsub("\n",'')
      end

      @organization.update_attributes!(params[:organization])
      notify.success _("Organization '%s' was updated.") % @organization["name"]

      if not search_validate(Organization, @organization.id, params[:search])
        notify.message _("'%s' no longer matches the current search criteria.") % @organization["name"],
                       :asynchronous => false
      end

      render :text => escape_html(result)

    rescue => error
      notify.exception error

      respond_to do |format|
        format.js { render :partial => "common/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def destroy
    found_errors= @organization.validate_destroy(current_organization)
    if found_errors
      notify.error found_errors
      render :text=>found_errors[1], :status=>:bad_request and return
    end

    id = @organization.cp_key
    OrganizationDestroyer.destroy @organization, :notify => true
    notify.success _("Organization '%s' has been scheduled for background deletion.") % @organization.name
    render :partial => "common/list_remove", :locals => {:id=> id, :name=> controller_display_name}
  rescue => error
    notify.exception error
    render :text=> error.to_s, :status=>:bad_request and return
  end

  def environments_partial
    @organization = Organization.find(params[:id])
    env_user_id = params[:user_id]?params[:user_id].to_s : nil
    if env_user_id == current_user.id.to_s && (!current_user.editable?)
      accessible_envs = KTEnvironment.systems_registerable(@organization)
    else
      accessible_envs = KTEnvironment.where(:organization_id => @organization.id)
    end

    setup_environment_selector(@organization, accessible_envs)
    @environment = first_env_in_path(accessible_envs, false, @organization)
    render :partial=>"environments", :locals=>{:accessible_envs => accessible_envs}
  end

  def events
    entries = @organization.events.collect {|e|
      entry = {}
      entry['timestamp'] = Date.parse(e['timestamp'])
      entry['message'] = e['messageText']
      entry
    }
    #entries.compact!  # To remove the nils inserted for rejected entries

    # TODO: add more/paging to these results instead of truncating at 250
    render :partial => 'events', :layout => "tupane_layout", :locals => {:entries => entries[0...250]}
  end

  def download_debug_certificate
    pem = @organization.debug_cert
    data = "#{pem[:key]}\n\n#{pem[:cert]}"
    send_data data,
      :filename => "#{@organization.name}-key-cert.pem",
      :type => "application/text"
  end



  protected

  def find_organization
    @organization = Organization.first(:conditions => { :cp_key => params[:id].to_s }) or begin
      message = _("Couldn't find organization with ID=%s") % params[:id]
      notify.error message
      execute_after_filters
      render :text => message, :status => :bad_request
    end
  end

  def find_organization_by_id
    begin
      @organization = Organization.find(params[:id])
      raise if @organization.nil?
    rescue => error
      notify.error _("Couldn't find organization with ID=%s") % params[:id]
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def setup_options
    @panel_options = { :title => _('Organizations'),
               :col => ['name'],
               :titles => [_('Name')],
               :create => _('Organization'),
               :create_label => _('+ New Organization'),
               :name => controller_display_name,
               :accessor => :cp_key,
               :ajax_load  => true,
               :ajax_scroll => items_organizations_path(),
               :enable_create => Organization.creatable?,
               :search_class=>Organization}
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def controller_display_name
    return 'organization'
  end

end
