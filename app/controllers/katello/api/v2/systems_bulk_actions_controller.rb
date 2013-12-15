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

    before_filter :find_organization, :only => [:bulk_add_system_groups, :bulk_remove_system_groups]
    before_filter :find_editable_systems, :only => [:bulk_add_system_groups, :bulk_remove_system_groups]
    before_filter :find_systems, :except => [:bulk_add_system_groups, :bulk_remove_system_groups]
    before_filter :find_groups, :only => [:bulk_add_system_groups, :bulk_remove_system_groups]
    before_filter :authorize

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
      bulk_delete_systems = lambda{ System.any_systems_deletable?(@systems) }
      bulk_edit_systems = lambda{ System.any_systems_editable?(@systems) }
      bulk_groups = lambda{ SystemGroup.assert_editable(@system_groups) }

      hash = {}
      #System groups are looked up via filters, handling permissions
      hash[:bulk_add_system_groups] = bulk_groups
      hash[:bulk_remove_system_groups] = bulk_groups
      hash[:install_content] = bulk_edit_systems
      hash[:update_content] = bulk_edit_systems
      hash[:remove_content] = bulk_edit_systems
      hash[:destroy_systems] = bulk_delete_systems
      hash
    end

    api :PUT, "/systems/add_system_groups",
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

    api :PUT, "/systems/remove_system_groups",
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

    api :PUT, "/systems/install_content", "Install content on one or more systems"
    param :ids, Array, :desc => "List of system ids", :required => true
    param :content_type, String,
      :desc => "The type of content.  The following types are supported: 'package', 'package_group' and 'errata'.",
      :required => true
    param :content, Array, :desc => "List of content (e.g. package names, package group names or errata ids)", :required => true
    def install_content
      if params[:content_type].blank?
        fail HttpErrors::BadRequest, _("A content_type must be provided.")
      end

      if params[:content].blank?
        fail HttpErrors::BadRequest, _("No content has been provided.")

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
        fail HttpErrors::BadRequest, _("A content_type must be provided.")
      end

      if params[:content].blank?
        fail HttpErrors::BadRequest, _("No content has been provided.")

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
        fail HttpErrors::BadRequest, _("A content_type must be provided.")
      end

      if params[:content].blank?
        fail HttpErrors::BadRequest, _("No content has been provided.")

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
      #deprecated find_systems
      @systems = System.find(params[:ids])
    end

    def find_groups
      @system_groups = SystemGroup.where(:id => params[:system_group_ids])
    end

    #takes a structure like:
    # included: {
    #      ids: [],
    #      search: 'search_term'
    #  },
    #  excluded: {
    #      ids: []
    #  }
    # and looks up editable systems for it
    def find_editable_systems
      params[:included] ||= {}
      params[:excluded] ||= {}
      @systems = []
      unless params[:included][:ids].blank?
        @systems = System.editable(@organization).where(:id => params[:included][:ids])
        @systems.where('id not in (?)', params[:excluded]) unless params[:excluded][:ids].blank?
      end

      if params[:included][:search]
        ids = find_system_ids_by_search(params[:included][:search])
        search_systems = System.editable(@organization).where(:id => ids)
        search_systems = search_systems.where('id not in (?)', params[:excluded][:ids]) unless params[:excluded][:ids].blank?
        @systems = @systems + search_systems
      end
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

  end
end
