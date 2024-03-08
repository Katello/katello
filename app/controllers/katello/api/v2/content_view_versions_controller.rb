module Katello
  class Api::V2::ContentViewVersionsController < Api::V2::ApiController
    include ::Api::V2::BulkHostsExtension
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_authorized_katello_resource, :only => [:show, :update, :promote, :destroy, :republish_repositories, :verify_checksum]
    before_action :find_content_view_from_version, :only => [:show, :update, :promote, :destroy, :republish_repositories, :verify_checksum]
    before_action :find_optional_readable_content_view, :only => [:index]

    before_action :find_environment, :only => [:index]
    before_action :find_environments, :only => [:promote]
    before_action :validate_promotable, :only => [:promote]
    before_action :authorize_destroy, :only => [:destroy]
    before_action :find_version_environments, :only => [:incremental_update]

    api :GET, "/content_view_versions", N_("List content view versions")
    api :GET, "/content_views/:content_view_id/content_view_versions", N_("List content view versions")
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :environment_id, :number, :desc => N_("Filter versions by environment"), :required => false
    param :version, String, :desc => N_("Filter versions by version number"), :required => false
    param :composite_version_id, :number, :desc => N_("Filter versions that are components in the specified composite version"), :required => false
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :include_applied_filters, :bool, :desc => N_("Whether or not to return filters applied to the content view version"), :required => false
    param :triggered_by_id, :number, :desc => N_("Filter composite versions whose publish was triggered by the specified component version"), :required => false
    param :file_id, :number, :desc => N_("Filter content view versions that contain the file")
    param :nondefault, :bool, :desc => N_("Filter out default content views"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentViewVersion)
    def index
      options = {
        :includes => [:content_view, :environments, :composite_content_views, :history => :task]
      }
      respond(:collection => scoped_search(index_relation.distinct, :version, :desc, options))
    end

    def index_relation
      version_number = params.permit(:version)[:version]
      versions = ContentViewVersion.readable
      versions = versions.triggered_by(params[:triggered_by_id]) if params[:triggered_by_id]
      versions = versions.with_organization_id(params[:organization_id]) if params[:organization_id]
      versions = versions.non_default_view if ::Foreman::Cast.to_bool(params[:nondefault])
      versions = versions.where(:content_view_id => @view.id) if @view
      versions = versions.for_version(version_number) if version_number
      versions = versions.in_environment(@environment) if @environment
      versions = versions.component_of(params[:composite_version_id]) if params[:composite_version_id]
      versions = versions.contains_file(params[:file_id]) if params[:file_id]
      versions
    end

    api :GET, "/content_view_versions/:id", N_("Show content view version")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :include_applied_filters, :bool, :desc => N_("Whether or not to return filters applied to the content view version"), :required => false
    def show
      respond :resource => @content_view_version
    end

    api :POST, "/content_view_versions/:id/promote", N_("Promote a content view version")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :force, :bool, :desc => N_("force content view promotion and bypass lifecycle environment restriction")
    param :environment_ids, Array, :desc => N_("Identifiers for Lifecycle Environment")
    param :description, String, :desc => N_("The description for the content view version promotion")
    def promote
      is_force = ::Foreman::Cast.to_bool(params[:force])
      task = async_task(::Actions::Katello::ContentView::Promote,
                        @content_view_version, @environments, is_force, params[:description])
      respond_for_async :resource => task
    end

    api :PUT, "/content_view_versions/:id", N_("Update a content view version")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :description, String, :desc => N_("The description for the content view version"), :required => true
    def update
      history = @content_view_version.history.publish.first
      if history.blank?
        fail HttpErrors::BadRequest, _("This content view version doesn't have a history.")
      else
        history.notes = params[:description]
        history.save!
        respond_for_show(:resource => @content_view_version)
      end
    end

    api :PUT, "/content_view_versions/:id/republish_repositories", N_("Forces a republish of the version's repositories' metadata")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    param :force, :bool, :desc => N_("Force metadata regeneration to proceed. Dangerous operation when version has repositories with the 'Complete Mirroring' mirroring policy")
    def republish_repositories
      mirror_complete_repos = @content_view_version.repositories.joins(:root).where(root: { mirroring_policy: ::Katello::RootRepository::MIRRORING_POLICY_COMPLETE })
      if mirror_complete_repos.size > 0 && !::Foreman::Cast.to_bool(params[:force])
        fail HttpErrors::BadRequest, _("Metadata republishing is dangerous on content view versions with repositories with the 'Complete Mirroring' mirroring policy.
Change the mirroring policy on these repositories: #{mirror_complete_repos.pluck(:name)} and try again.
Alternatively, use the 'force' parameter to regenerate metadata locally. New versions of the content view will continue to use upstream metadata for repositories with 'Complete Mirroring'.")
      end
      task = async_task(::Actions::Katello::ContentViewVersion::RepublishRepositories, @content_view_version, force: ::Foreman::Cast.to_bool(params[:force]))
      respond_for_async :resource => task
    end

    api :DELETE, "/content_view_versions/:id", N_("Remove content view version")
    param :id, :number, :desc => N_("Content view version identifier"), :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentViewVersion::Destroy, @content_view_version)
      respond_for_async :resource => task
    end

    api :POST, "/content_view_versions/incremental_update", N_("Perform an Incremental Update on one or more Content View Versions")
    param :content_view_version_environments, Array do
      param :content_view_version_id, :number, :desc => N_("Content View Version Ids to perform an incremental update on.  May contain composites as well as one or more components to update.")
      param :environment_ids, Array, :desc => N_("The list of environments to promote the specified Content View Version to (replacing the older version)")
    end
    param :description, String, :desc => N_("The description for the new generated Content View Versions")
    param :resolve_dependencies, :bool, :desc => N_("If true, when adding the specified errata or packages, any needed dependencies will be copied as well. Defaults to true")
    param :propagate_all_composites, :bool, :desc => N_("If true, will publish a new composite version using any specified content_view_version_id that has been promoted to a lifecycle environment")
    param :add_content, Hash do
      param :errata_ids, Array, :desc => "Errata ids to copy into the new versions"
      param :package_ids, Array, :desc => "Package ids to copy into the new versions"
      param :deb_ids, Array, :desc => "Deb Package ids to copy into the new versions"
    end
    param :update_hosts, Hash, :desc => N_("After generating the incremental update, apply the changes to the specified hosts.  Only Errata are supported currently.") do
      param :included, Hash, :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for host to perform an action on")
        param :ids, Array, :required => false, :desc => N_("List of host ids to perform an action on")
      end
      param :excluded, Hash, :required => false, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of host ids to exclude and not run an action on")
      end
    end
    def incremental_update
      if params[:add_content].values.flatten.empty?
        fail HttpErrors::BadRequest, _("Incremental update requires at least one content unit")
      end
      any_environments = params[:content_view_version_environments].any? { |cvve| cvve[:environment_ids].try(:any?) }
      if params[:add_content]&.key?(:errata_ids) && params[:update_hosts] && any_environments
        hosts = calculate_hosts_for_incremental(params[:update_hosts], params[:propagate_to_composites])
      else
        hosts = []
      end

      validate_content(params[:add_content])
      resolve_dependencies = params.fetch(:resolve_dependencies, true)
      task = async_task(::Actions::Katello::ContentView::IncrementalUpdates, @content_view_version_environments, @composite_version_environments,
                        params[:add_content], resolve_dependencies, hosts, params[:description])
      respond_for_async :resource => task
    end

    api :POST, "/content_view_versions/:id/verify_checksum", N_("Verify checksum of repository contents in the content view version")
    param :id, :number, :required => true, :desc => N_("Content view version identifier")
    def verify_checksum
      task = async_task(::Actions::Katello::ContentViewVersion::VerifyChecksum, @content_view_version)
      respond_for_async :resource => task
    end

    private

    def calculate_hosts_for_incremental(bulk_params, use_composites)
      if bulk_params[:included].try(:[], :search)
        version_environments = find_version_environments_for_hosts(use_composites)
        restrict_hosts = lambda do |relation|
          if version_environments.any?
            errata = Erratum.with_identifiers(params[:add_content][:errata_ids])
            content_facets = Host::ContentFacet.in_content_view_version_environments(version_environments).with_applicable_errata(errata)
            relation.where(:id => content_facets.pluck(:host_id))
          else
            relation.where("1=0")
          end
        end
      else
        restrict_hosts = nil
      end

      find_bulk_hosts(:edit_hosts, params[:update_hosts], restrict_hosts)
    end

    def find_content_view_from_version
      @view = @content_view_version.content_view
      if @view&.default? && params[:action] == "promote"
        fail HttpErrors::BadRequest, _("The default content view cannot be promoted")
      end
    end

    def find_optional_readable_content_view
      @view = ContentView.readable.find_by(:id => params[:content_view_id])
      if params[:content_view_id] && !@view
        fail HttpErrors::NotFound, _("Couldn't find content view with id: '%s'") % params[:content_view_id]
      end
    end

    def find_publishable_content_view
      @view = ContentView.publishable.find_by(:id => params[:content_view_id])
      throw_resource_not_found(name: 'product', id: params[:product_id]) if @view.nil?
    end

    def find_version_environments
      #Generates a data structure for incremental update:
      # [{:content_view_version => ContentViewVersion, :environments => [KTEnvironment]}]

      list = params[:content_view_version_environments]
      fail _("At least one Content View Version must be specified") if list.empty?

      @content_view_version_environments = []
      @composite_version_environments = []
      list.each do |combination|
        version_environment = {
          :content_view_version => ContentViewVersion.find(combination[:content_view_version_id]),
          :environments => KTEnvironment.where(:id => combination[:environment_ids])
        }

        view = version_environment[:content_view_version].content_view
        return deny_access(_("You are not allowed to publish Content View %s") % view.name) unless view.publishable? && view.promotable_or_removable?

        not_promotable = version_environment[:environments].select { |env| !env.promotable_or_removable? }
        unless not_promotable.empty?
          return deny_access(_("You are not allowed to promote to Environments %s") % un_promotable.map(&:name).join(', '))
        end

        unless combination[:environment_ids].blank?
          not_found = combination[:environment_ids].map(&:to_s) - version_environment[:environments].map { |env| env.id.to_s }
          fail _("Could not find Environment with ids: %s") % not_found.join(', ') unless not_found.empty?
        end

        if view.composite?
          @composite_version_environments << version_environment
        else
          @content_view_version_environments << version_environment
          @composite_version_environments += lookup_all_composites(version_environment[:content_view_version]) if params[:propagate_all_composites]
        end
      end
      @composite_version_environments.uniq! { |cve| cve[:content_view_version] }
    end

    def lookup_all_composites(component)
      component.composites.select { |c| c.environments.any? }.map do |composite|
        {
          :content_view_version => composite,
          :environments => composite.environments
        }
      end
    end

    def find_version_environments_for_hosts(include_composites)
      if include_composites
        version_environments_for_systems_map = {}
        @content_view_version_environments.each do |version_environment|
          version_environment[:content_view_version].composites.each do |composite_version|
            version_environments_for_systems_map[composite_version.id] ||= {:content_view_version => composite_version,
                                                                            :environments => composite_version.environments}
          end
        end

        version_environments_for_systems_map.values
      else
        @content_view_version_environments.select { |ve| !ve[:environments].blank? }
      end
    end

    def find_environment
      return unless params.key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
    end

    def validate_content(content)
      if content[:errata_ids]
        errata = Erratum.with_identifiers(content[:errata_ids])
        not_found_count = content[:errata_ids].length - errata.length
        if not_found_count > 0
          fail _("Could not find %{count} errata.  Only found: %{found}") %
                   { :count => not_found_count, :found => errata.pluck(:errata_id).join(',') }
        end
      end

      if content[:package_ids]
        fail _("package_ids is not an array") unless content[:package_ids].is_a?(Array)
      end

      if content[:deb_ids]
        fail _("deb_ids is not an array") unless content[:deb_ids].is_a?(Array)
      end
    end

    def find_environments
      @environments = KTEnvironment.where(:id => params[:environment_ids])
    end

    def validate_promotable
      fail HttpErrors::BadRequest, _("Could not find environments for promotion") if @environments.blank?
      return deny_access unless @environments.all?(&:promotable_or_removable?) && @content_view_version.content_view.promotable_or_removable?
      true
    end

    def authorize_destroy
      return deny_access unless @content_view_version.content_view.deletable?
      true
    end
  end
end
