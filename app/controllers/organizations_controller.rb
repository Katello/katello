
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

class OrganizationsController < ApplicationController
  include AutoCompleteSearch
  respond_to :html, :js
  before_filter :find_organization, :only => [:edit, :update, :destroy, :events, :default_info]
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
        User.creatable?
      else
        params[:user_id] &&
            ((current_user.id.to_s == params[:user_id].to_s) || current_user.editable?)
      end
    end

    {
      :index => index_test,
      :items => index_test,
      :show => index_test,
      :auto_complete_search => index_test,
      :new => create_test,
      :create => create_test,
      :default_label => create_test,
      :edit => read_test,
      :update => edit_test,
      :destroy => delete_test,
      :environments_partial => environments_partial_test,
      :events => read_test,
      :download_debug_certificate => edit_test,
      :default_info => read_test
    }
  end

  def param_rules
    {
      :create => {:organization => [:name, :description, :label], :environment => [:name, :description, :label]},
      :update => {:organization  => [:name, :description, :service_level]}
    }
  end

  def section_id
    'operations'
  end

  def menu_definition
    {:index => :admin_menu}.with_indifferent_access
  end

  def items
    ids = Organization.without_deleting.readable.collect(&:id)
    render_panel_direct(Organization, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
                        {:default_field => :name, :filter=>[{"id"=>ids}]})
  end

  def show
    if params[:id] == 'new'
      render :partial=>"new"
    else
      find_organization
      render :partial=>"common/list_update", :locals => {:item => @organization, :accessor => 'label', :columns => ['name']}
    end
  end

  def create
    org_label_assigned = ""
    org_params = params[:organization]
    org_params[:label], org_label_assigned = generate_label(org_params[:name], 'organization') if org_params[:label].blank?
    @organization = Organization.new(:name => org_params[:name], :label => org_params[:label], :description => org_params[:description])
    @organization.save!

    env_label_assigned = ""
    env_params = params[:environment]
    if env_params[:name].present?
      if env_params[:label].blank?
        env_params[:label], env_label_assigned = generate_label(env_params[:name], 'environment') if env_params[:label].blank?
      end

      @new_env = KTEnvironment.new(:name => env_params[:name], :label => env_params[:label], :description => env_params[:description])
      @new_env.organization = @organization
      @new_env.prior = @organization.library
      @new_env.save!
    end

    notify.success _("Organization '%s' was created.") % @organization["name"]
    notify.message org_label_assigned unless org_label_assigned.blank?

    if search_validate(Organization, @organization.id, params[:search])
      if @new_env.nil?
        notify.message _("Click on 'Add Environment' to create the first environment")
      else
        notify.message env_label_assigned unless env_label_assigned.blank?
      end
      render :partial=>"common/list_item", :locals=>{:item=>@organization, :accessor=>"label", :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @organization["name"]
      render :json => { :no_match => true }
    end

  ensure
    if @organization && @organization.persisted? && @new_env && @new_env.new_record?
      @organization.destroy
    end
  end

  def edit
    @org_label = ""
    user_default_org = current_user.default_org
    if user_default_org && !user_default_org.nil?
      if user_default_org == @organization
        @org_label = _("This is your default organization.")
      else
        @org_label = _("Make this my default organization.")
      end
    else
      @org_label = _("Make this my default organization.")
    end
    @env_choices =  @organization.environments.collect {|p| [ p.name, p.name ]}
    render :partial=>"edit", :locals=>{:organization=>@organization, :editable=>@organization.editable?, :name => controller_display_name, :org_label=>@org_label}
  end

  def update
    result = params[:organization].values.first

    @organization.name = params[:organization][:name] unless params[:organization][:name].nil?

    unless params[:organization][:description].nil?
      result = @organization.description = params[:organization][:description].gsub("\n",'')
    end

    unless params[:organization][:service_level].nil?
      result = @organization.service_level = params[:organization][:service_level]
    end

    @organization.save!
    notify.success _("Organization '%s' was updated.") % @organization["name"]

    if not search_validate(Organization, @organization.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @organization["name"],
                     :asynchronous => false
    end

    render :text => escape_html(result)
  end

  def destroy
    found_errors= @organization.validate_destroy(current_organization)
    if found_errors
      notify.error found_errors
      render :text=>found_errors[1], :status=>:bad_request and return
    end

    # log off all users for this organization
    # TODO - since we use cookie-based session this is not possible (need to switch over to db-based sessions first)

    # schedule background deletion
    id = @organization.label
    OrganizationDestroyer.destroy @organization, :notify => true
    notify.success _("Organization '%s' has been scheduled for background deletion.") % @organization.name
    render :partial => "common/list_remove", :locals => {:id=> id, :name=> controller_display_name}
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
    render :partial => 'events', :locals => {:entries => entries[0...250]}
  end

  def download_debug_certificate
    pem = @organization.debug_cert
    data = "#{pem[:key]}\n\n#{pem[:cert]}"
    send_data data,
      :filename => "#{@organization.name}-key-cert.pem",
      :type => "application/text"
  end

  def default_info
    Organization.check_informable_type!(params[:informable_type])
    task = TaskStatus.find_by_id(@organization.apply_info_task_id)
    task_state = (task.blank? ? nil : task.state)
    task_uuid = (task.blank? ? nil : task.uuid)
    render :partial => "default_info",
      :locals => { :org => @organization, :informable_type => params[:informable_type], :task_state => task_state, :task_uuid => task_uuid }
  end

  protected

  def find_organization
    @organization = Organization.find_by_label(params[:id].to_s)
    if @organization.blank?
      message = _("Couldn't find organization with ID %s") % params[:id]
      notify.error message
      execute_after_filters
      render :text => message, :status => :not_found and return false
    end
  end

  def find_organization_by_id
    @organization = Organization.find(params[:id])
  end

  def setup_options
    @panel_options = { :title => _('Organizations'),
               :col => ['name'],
               :titles => [_('Name')],
               :create => _('Organization'),
               :create_label => _('+ New Organization'),
               :name => controller_display_name,
               :accessor => :label,
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

  private

  def default_notify_options
    super.merge :organization => nil
  end

end
