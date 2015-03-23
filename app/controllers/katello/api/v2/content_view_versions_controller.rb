#
# Copyright 2014 Red Hat, Inc.
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
  class Api::V2::ContentViewVersionsController < Api::V2::ApiController
    include Concerns::Api::V2::BulkSystemsExtensions

    before_filter :find_content_view_version, :only => [:show, :promote, :destroy]
    before_filter :find_content_view, :except => [:incremental_update]
    before_filter :find_environment, :only => [:promote, :index]
    before_filter :authorize_promotable, :only => [:promote]
    before_filter :authorize_destroy, :only => [:destroy]
    before_filter :load_search_service, :only => [:incremental_update]
    before_filter :find_version_environments, :only => [:incremental_update]

    api :GET, "/content_view_versions", N_("List content view versions")
    api :GET, "/content_views/:content_view_id/content_view_versions", N_("List content view versions")
    param :content_view_id, :identifier, :desc => N_("Content view identifier"), :required => false
    param :environment_id, :identifier, :desc => N_("Filter versions by environment"), :required => false
    param :version, String, :desc => N_("Filter versions by version number"), :required => false
    param :composite_version_id, :identifier, :desc => N_("Filter versions that are components in the specified composite version"), :required => false
    def index
      version_number = params.permit(:version)[:version]
      versions = ContentViewVersion
      versions = versions.where(:content_view_id => @view.id) if @view
      versions = versions.for_version(version_number) if version_number
      versions = versions.in_environment(@environment) if @environment
      versions = versions.component_of(params[:composite_version_id]) if params[:composite_version_id]
      versions = versions.includes(:content_view).includes(:environments).includes(:composite_content_views).includes(:history => :task)

      collection = {:results  => versions.order('major desc, minor desc'),
                    :subtotal => versions.count,
                    :total    => versions.count
                   }

      params[:sort_by] = 'major'
      params[:sort_order] = 'desc'

      respond(:collection => collection, :layout => 'index')
    end

    api :GET, "/content_view_versions/:id", N_("Show content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    def show
      respond :resource => @version
    end

    api :POST, "/content_view_versions/:id/promote", N_("Promote a content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    param :force, :bool, :desc => N_("force content view promotion and bypass lifecycle environment restriction")
    param :environment_id, :identifier
    def promote
      is_force = params[:force].is_a?(String) ? params[:force].to_bool : params[:force]
      task = async_task(::Actions::Katello::ContentView::Promote,
                        @version, @environment, is_force)
      respond_for_async :resource => task
    end

    api :DELETE, "/content_view_versions/:id", N_("Remove content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentViewVersion::Destroy, @version)
      respond_for_async :resource => task
    end

    api :POST, "/content_view_versions/incremental_update", N_("Perform an Incremental Update on one or more Content View Versions")
    param :content_view_version_environments, Array do
      param :content_view_version_id, :identifier, :desc => N_("Content View Version Ids to perform an incremental update on.  May contain composites as well as one or more components to update.")
      param :environment_ids, Array, :desc => N_("The list of environments to promote the specified Content View Version to (replacing the older version).")
    end
    param :description, String, :desc => N_("The description for the new generated Content View Versions")
    param :resolve_dependencies, :bool, :desc => N_("If true, when adding the specified errata or packages, any needed dependencies will be copied as well.")
    param :propagate_all_composites, :bool, :desc => N_("If true, will publish a new composite version using any specified content_view_version_id that has been promoted to a lifecycle environment.")
    param :add_content, Hash  do
      param :errata_ids, Array, :desc => "Errata uuids to copy into the new versions."
      param :package_ids, Array, :desc => "Package uuids to copy into the new versions."
      param :puppet_module_ids, Array, :desc => "Puppet Modules to copy into the new versions."
    end
    param :update_systems, Hash, :desc => N_("After generating the incremental update, apply the changes to the specified systems.  Only Errata are supported currently.") do
      param :included, Hash, :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for systems to perform an action on")
        param :ids, Array, :required => false, :desc => N_("List of system ids to perform an action on")
      end
      param :excluded, Hash, :required => false, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of system ids to exclude and not run an action on")
      end
      param :update_all_systems, :bool, :required => false, :desc => N_("Update all editable and applicable systems, not just ones using the selected Content View Versions and Environments")
    end
    def incremental_update
      if params[:add_content] && params[:add_content].key?(:errata_ids) && params[:update_systems]
        systems = calculate_systems_for_incremental(params[:update_systems], params[:propagate_to_composites])
      else
        systems = []
      end

      validate_content(params[:add_content])
      task = async_task(::Actions::Katello::ContentView::IncrementalUpdates, @version_environments, @composite_version_environments, params[:add_content],
                        params[:resolve_dependencies], systems, params[:description])
      respond_for_async :resource => task
    end

    private

    def calculate_systems_for_incremental(bulk_params, use_composites)
      if bulk_params[:update_all_systems]
        version_environments  = find_version_environments_for_systems(use_composites)
        restrict_systems = lambda do |relation|
          errata = Erratum.where(:uuid => params[:add_content][:errata_ids])
          relation.in_content_view_version_environments(version_environments).with_applicable_errata(errata)
        end
      else
        restrict_systems = nil
      end

      find_bulk_systems(:editable, params[:update_systems], restrict_systems)
    end

    def find_content_view_version
      @version = ContentViewVersion.find(params[:id])
    end

    def find_content_view
      @view = @version ? @version.content_view : ContentView.where(:id => params[:content_view_id]).first
      if @view && @view.default? && params[:action] == "promote"
        fail HttpErrors::BadRequest, _("The default content view cannot be promoted")
      end
    end

    def find_version_environments
      #Generates a data structure for incremental update:
      # [{:content_view_version => ContentViewVersion, :environments => [KTEnvironment]}]

      list = params[:content_view_version_environments]
      fail _("At least one Content View Version must be specified") if list.empty?

      @version_environments = []
      @composite_version_environments = []
      list.each do |combination|
        version_environment = {
          :content_view_version => ContentViewVersion.find(combination[:content_view_version_id]),
          :environments =>  KTEnvironment.where(:id => combination[:environment_ids])
        }

        view = version_environment[:content_view_version].content_view
        return deny_access(_("You are not allowed to publish Content View %s") % view.name) unless view.publishable? && view.promotable_or_removable?

        not_promotable = version_environment[:environments].select { |env| !env.promotable_or_removable? }
        unless not_promotable.empty?
          return deny_access(_("You are not allowed to promote to Environments %s") % un_promotable.map(&:name).join(', '))
        end

        not_found = combination[:environment_ids].map(&:to_s) - version_environment[:environments].map { |env| env.id.to_s }
        fail _("Could not find Environment with ids: %s") % not_found.join(', ') unless not_found.empty?

        if view.composite?
          @composite_version_environments << version_environment
        else
          @version_environments << version_environment
          @composite_version_environments += lookup_all_composites(version) if params[:propagate_all_composites]
        end
      end
      @composite_version_environments.uniq! { |cve| cve[:content_view_version] }
    end

    def lookup_all_composites(component)
      component.composites.select { |c| c.environment.any? }.map do |composite|
        {
          :content_view_version => composite,
          :environments =>  composite.environments
        }
      end
    end

    def find_version_environments_for_systems(include_composites)
      if include_composites
        version_environments_for_systems_map = {}
        @version_environments.each do |version_environment|
          version_environment[:content_view_version].composites.each do |composite_version|
            version_environments_for_systems_map[composite_version.id] ||= {:content_view_version => composite_version,
                                                                            :environments => composite_version.environments}
          end
        end
        version_environments_for_systems_map.values
      else
        @version_environments
      end
    end

    def find_environment
      return unless params.key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
    end

    def validate_content(content)
      if content[:errata_ids]
        errata = Erratum.where(:uuid => content[:errata_ids])
        not_found = content[:errata_ids] - errata.pluck(:uuid)
        fail _("Could not find errata with id: %s") % not_found.join(", ") unless not_found.empty?
      end

      if content[:package_ids]
        fail _("package_ids is not an array") unless content[:package_ids].is_a?(Array)
      end

      if content[:puppet_module_ids]
        fail _("puppet_module_ids is not an array") unless content[:puppet_module_ids].is_a?(Array)
      end
    end

    def authorize_promotable
      return deny_access unless @environment.promotable_or_removable? && @version.content_view.promotable_or_removable?
      true
    end

    def authorize_destroy
      return deny_access unless @version.content_view.deletable?
      true
    end
  end
end
