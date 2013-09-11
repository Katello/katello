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

class Api::V2::SystemsBulkActionsController < Api::V2::SystemsController

  before_filter :find_systems
  before_filter :authorize

  def rules
    bulk_delete_systems = lambda{ System.any_systems_deletable?(@systems) }
    bulk_edit_systems = lambda{ System.any_systems_editable?(@systems) }

    hash = super
    hash[:bulk_add_system_groups] = bulk_edit_systems
    hash[:bulk_remove_system_groups] = bulk_edit_systems
    hash[:install_content] = bulk_edit_systems
    hash[:update_content] = bulk_edit_systems
    hash[:remove_content] = bulk_edit_systems
    hash[:destroy_systems] = bulk_delete_systems
    hash
  end

  api :PUT, "/systems/add_system_groups",
      "Add one or more system groups to one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  param :system_group_ids, Array, :desc => "List of system group ids", :required => true
  def bulk_add_system_groups
    successful_systems = []
    failed_systems = []

    unless params[:system_group_ids].blank?
      @system_groups = SystemGroup.where(:id => params[:system_group_ids])

      # perform some pre-validation of the request
      # e.g. are any of the groups not editable or will their membership be exceeded by the request?
      invalid_perms = []
      max_systems_exceeded = []

      @system_groups.each do |system_group|
        if !system_group.editable?
          invalid_perms.push(system_group.name)
        elsif (system_group.max_systems != SystemGroup::UNLIMITED_SYSTEMS) && ((system_group.systems.length + @systems.length) > system_group.max_systems)
          max_systems_exceeded.push(system_group.name)
        end
      end

      if !invalid_perms.empty?
        raise HttpErrors::BadRequest, _("Group membership modification is not allowed for system group(s): %s") % invalid_perms.join(', ')
      elsif !max_systems_exceeded.empty?
        raise HttpErrors::BadRequest, _("Maximum number of systems exceeded for system group(s): %s") % max_systems_exceeded.join(', ')
      end

      @systems.each do |system|
        begin
          system.system_group_ids = (system.system_group_ids + @system_groups.collect{ |g| g.id }).uniq
          system.save!
          successful_systems.push(system.name)
        rescue
          failed_systems.push(system.name)
        end
      end

      display_message = _("Successfully added system groups to selected systems.")
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  api :PUT, "/systems/remove_system_groups",
      "Remove one or more system groups to one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  param :system_group_ids, Array, :desc => "List of system group ids", :required => true
  def bulk_remove_system_groups
    successful_systems = []
    failed_systems = []
    groups_info = {} # hash to store system group id to name mapping
    systems_summary = {} # hash to store system to system group mapping, for groups removed from the system

    unless params[:system_group_ids].blank?
      @system_groups = SystemGroup.where(:id => params[:system_group_ids])

      # does the user have permission to modify the requested system groups?
      invalid_perms = []
      @system_groups.each do |system_group|
        if !system_group.editable?
          invalid_perms.push(system_group.name)
        end
        groups_info[system_group.id] = system_group.name
      end

      if !invalid_perms.empty?
        raise HttpErrors::BadRequest, _("Group membership modification is not allowed for system group(s): %s") % invalid_perms.join(', ')
      end

      @systems.each do |system|
        begin
          groups_removed = system.system_group_ids & groups_info.keys
          system.system_group_ids = (system.system_group_ids - groups_info.keys).uniq
          system.save!

          systems_summary[system] = groups_removed.collect{ |g| groups_info[g] }
          successful_systems.push(system.name)
        rescue
          failed_systems.push(system.name)
        end
      end

      display_message = _("Successfully removed system groups from selected systems.")
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  api :PUT, "/systems/install_content", "Install content on one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package', 'package_group' and 'errata'.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package names, package group names or errata ids)", :required => true
  def install_content
    if params[:content_type].blank?
      raise HttpErrors::BadRequest, _("A content_type must be provided.")
    end

    if params[:content].blank?
      raise HttpErrors::BadRequest, _("No content has been provided.")

    else
      if params[:content_type].to_sym == :package
        @systems.each{ |system| system.install_packages params[:content] }
        display_message = _("Successfully scheduled install of package(s): %s") % params[:content].join(', ')

      elsif params[:content_type].to_sym == :package_group
        @systems.each{ |system| system.install_package_groups params[:content] }
        display_message = _("Successfully scheduled install of package group(s): %s") % params[:content].join(', ')

      elsif params[:content_type].to_sym == :errata
        @systems.each{ |system| system.install_errata params[:content] }
        display_message = _("Successfully scheduled install of errata(s): %s") % params[:content].join(', ')
      end
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  api :PUT, "/systems/update_content", "Update content on one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package' and 'package_group.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package or package group names)", :required => true
  def update_content
    if params[:content_type].blank?
      raise HttpErrors::BadRequest, _("A content_type must be provided.")
    end

    if params[:content].blank?
      raise HttpErrors::BadRequest, _("No content has been provided.")

    else
      if params[:content_type].to_sym == :package
        @systems.each do |system|
          system.update_packages params[:content]
        end

        if params[:content].blank?
          display_message = _("Successfully scheduled update of all packages")
        else
          display_message = _("Successfully scheduled update of package(s): %s") % params[:content].join(', ')
        end

      elsif params[:content_type].to_sym == :package_group
        @systems.each{ |system| system.install_package_groups params[:content] }
        display_message = _("Successfully scheduled update of package group(s): %s") % params[:content].join(', ')
      end
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  api :PUT, "/systems/remove_content", "Remove content on one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  param :content_type, String,
        :desc => "The type of content.  The following types are supported: 'package' and 'package_group.",
        :required => true
  param :content, Array, :desc => "List of content (e.g. package or package group names)", :required => true
  def remove_content
    if params[:content_type].blank?
      raise HttpErrors::BadRequest, _("A content_type must be provided.")
    end

    if params[:content].blank?
      raise HttpErrors::BadRequest, _("No content has been provided.")

    else
      if params[:content_type].to_sym == :package
        @systems.each{ |system| system.uninstall_packages params[:content] }
        display_message = _("Successfully scheduled uninstall of package(s): %s") % params[:content].join(', ')

      elsif params[:content_type].to_sym == :package_group
        @systems.each{ |system| system.uninstall_package_groups params[:content] }
        display_message = _("Successfully scheduled uninstall of package group(s): %s") % params[:content].join(', ')
      end
    end

    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  api :PUT, "/systems/destroy", "Destroy one or more systems"
  param :ids, Array, :desc => "List of system ids", :required => true
  def destroy_systems
    @systems.each{ |system| system.destroy }
    display_message = _("Successfully removed %s systems") % @systems.length
    respond_for_show :template => 'bulk_action', :resource => { 'displayMessage' => display_message }
  end

  private

  def find_systems
    @systems = System.find(params[:ids])
  end

end
