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

module Katello
class Api::V2::SystemsBulkActionsController < Api::V2::ApiController

  before_filter :find_organization
  before_filter :load_search_service
  before_filter :find_editable_systems, :except => [:destroy_systems, :applicable_errata]
  before_filter :find_deletable_systems, :only => [:destroy_systems]
  before_filter :find_readable_systems, :only => [:applicable_errata]

  before_filter :find_environment, :only => [:environment_content_view]
  before_filter :find_content_view, :only => [:environment_content_view]

  before_filter :find_groups, :only => [:bulk_add_system_groups, :bulk_remove_system_groups]
  before_filter :validate_content_action, :only => [:install_content, :update_content, :remove_content]
  before_filter :authorize

  PARAM_ACTIONS = {
      :install_content => {
          :package => :install_packages,
          :package_group => :install_package_groups,
          :errata => :install_errata
      },
      :update_content => {
          :package => :update_packages,
          :package_group => :update_package_groups,
      },
      :remove_content => {
          :package => :uninstall_packages,
          :package_group => :uninstall_package_groups
      }
  }.with_indifferent_access

  def_param_group :bulk_params do
    param :include, Hash, :required => true, :action_aware => true do
      param :search, String, :required => false, :desc => "Search string for systems to perform an action on"
      param :ids, Array, :required => false, :desc => "List of system ids to perform an action on"
    end
    param :exclude, Hash, :required => true, :action_aware => true do
      param :ids, Array, :required => false, :desc => "List of system ids to exclude and not run an action on"
    end
  end

  def rules
    bulk_groups = lambda{ SystemGroup.assert_editable(@system_groups) }
    registerable = lambda{ @environment.systems_registerable? && @view.subscribable?}

    hash = {}
    hash[:bulk_add_system_groups] = bulk_groups
    hash[:bulk_remove_system_groups] = bulk_groups
    #the actions do validation upon system lookup.  See find_*_systems filters
    hash[:applicable_errata] = lambda{true}
    hash[:install_content] = lambda{true}
    hash[:update_content] = lambda{true}
    hash[:remove_content] = lambda{true}
    hash[:destroy_systems] = lambda{true}
    hash[:environment_content_view] = registerable
    hash
  end

  api :PUT, "/systems/bulk/add_system_groups",
      "Add one or more system groups to one or more systems"
  param_group :bulk_params
  param :system_group_ids, Array, :desc => "List of system group ids", :required => true
  def bulk_add_system_groups
    unless params[:system_group_ids].blank?
      display_messages = []

      @system_groups.each do |group|
        pre_group_count = group.system_ids.count
        group.system_ids =  (group.system_ids + @systems.collect { |s| s.id }).uniq
        group.save!

        final_count = group.system_ids.count - pre_group_count
        display_messages << _("Successfully added %{count} system(s) to system group %{group}.") %
            {:count => final_count, :group => group.name }
      end
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
  end

  api :PUT, "/systems/bulk/remove_system_groups",
      "Remove one or more system groups to one or more systems"
  param_group :bulk_params
  param :system_group_ids, Array, :desc => "List of system group ids", :required => true
  def bulk_remove_system_groups
    display_messages = []

    unless params[:system_group_ids].blank?
      @system_groups.each do |group|
        pre_group_count = group.system_ids.count
        group.system_ids =  (group.system_ids - @systems.collect { |s| s.id }).uniq
        group.save!

        final_count = pre_group_count - group.system_ids.count
        display_messages << _("Successfully removed %{count} systems from system group %{group}.") %
            {:count => final_count, :group => group.name }
      end
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
  end

  api :POST, "/systems/bulk/applicable_errata",
      "Fetch applicable errata for a system."
  param_group :bulk_params
  def applicable_errata
    @search_service = nil #reload search service after systems are loaded
    load_search_service
    results = item_search(Katello::Errata, params, {}) do |service|
      Katello::Errata.search_applicable_for_consumers(@systems.collect{|i| i.uuid}, service)
    end

    respond_for_index(:collection => results)
  end

  api :PUT, "/systems/bulk/install_content", "Install content on one or more systems"
  param_group :bulk_params
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package', 'package_group' and 'errata'.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package names, package group names or errata ids)", :required => true
  def install_content
    content_action
  end

  api :PUT, "/systems/bulk/update_content", "Update content on one or more systems"
  param_group :bulk_params
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package' and 'package_group.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package or package group names)", :required => true
  def update_content
    content_action
  end

  api :PUT, "/systems/bulk/remove_content", "Remove content on one or more systems"
  param_group :bulk_params
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package' and 'package_group.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package or package group names)", :required => true
  def remove_content
    content_action
  end

  api :PUT, "/systems/bulk/destroy", "Destroy one or more systems"
  param_group :bulk_params
  def destroy_systems
    @systems.each{ |system| system.destroy }
    display_message = _("Successfully removed %s systems") % @systems.length
    respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => [display_message] }
  end

  api :PUT, "/systems/bulk/environment_content_view", "Assign the environment and content view to one or more systems"
  param_group :bulk_params
  param :environment_id, Integer
  param :content_view_id, Integer
  def environment_content_view
    @systems.each do |system|
      system.content_view = @view
      system.environment = @environment
      system.save!
    end
    display_message = _("Successfully reassigned %{count} systems to %{cv} in %{env}.") %
        {:count => @systems.length, :cv => @view.name, :env => @environment.name}
    respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => [display_message]}
  end

  private

  def find_groups
    @system_groups = SystemGroup.where(:id => params[:system_group_ids])
  end

  def find_readable_systems
    find_systems(:readable)
  end

  def find_editable_systems
    find_systems(:editable)
  end

  def find_deletable_systems
    find_systems(:deletable)
  end

  def find_systems(perm_method)
    #works on a structure of param_group bulk_params and transforms it into a list of systems
    params[:included] ||= {}
    params[:excluded] ||= {}
    @systems = []
    unless params[:included][:ids].blank?
      @systems = System.send(perm_method, @organization).where(:id => params[:included][:ids])
      @systems.where('id not in (?)', params[:excluded]) unless params[:excluded][:ids].blank?
    end

    if params[:included][:search]
      ids = find_system_ids_by_search(params[:included][:search])
      search_systems = System.send(perm_method, @organization).where(:id => ids)
      search_systems = search_systems.where('id not in (?)', params[:excluded][:ids]) unless params[:excluded][:ids].blank?
      @systems = @systems + search_systems
    end

    if params[:included][:ids].blank? && params[:included][:search].nil?
      fail HttpErrors::BadRequest, _("No systems have been specified.")
    elsif @systems.empty?
      fail HttpErrors::Forbidden, _("Action unauthorized to be performed on selected systems.")
    end
    @systems
  end

  def find_system_ids_by_search(search)
    options = {
        :filters       => System.readable_search_filters(@organization),
        :load_records? => false,
        :full_result => true,
        :fields => [:id]
    }
    item_search(System, {:search => search}, options)[:results].collect{|i| i.id}
  end

  def validate_group_membership_limit
    max_systems_exceeded = []
    system_ids = @systems.collect{|i| i.id}

    @system_groups.each do |system_group|
      computed_count = (system_group.system_ids + system_ids).uniq.length
      if system_group.max_systems != SystemGroup::UNLIMITED_SYSTEMS && computed_count > system_group.max_systems
        max_systems_exceeded.push(system_group.name)
      end
    end

    if !max_systems_exceeded.empty?
      fail HttpErrors::BadRequest, _("Maximum number of systems exceeded for system group(s): %s") % max_systems_exceeded.join(', ')
    end
  end

  def content_action
    action = Katello::BulkActions.new(User.current, @organization, @systems)
    job = action.send(PARAM_ACTIONS[params[:action]][params[:content_type]],  params[:content])
    respond_for_show :template => 'job', :resource => job
  end

  def validate_content_action
    fail HttpErrors::BadRequest, _("A content_type must be provided.") if params[:content_type].blank?
    fail HttpErrors::BadRequest, _("No content has been provided.") if params[:content].blank?

    if PARAM_ACTIONS[params[:action]][params[:content_type]].nil?
      fail HttpErrors::BadRequest, _("Invalid content type %s") % params[:content_type]
    end
  end

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
  end

  def find_content_view
    @view = ContentView.find(params[:content_view_id])
  end

end
end
