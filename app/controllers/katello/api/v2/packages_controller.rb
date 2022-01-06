module Katello
  class Api::V2::PackagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package"), :resource => "packages")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_repositories, :only => [:auto_complete_name, :auto_complete_arch]
    before_action :find_hosts, :only => :index

    def auto_complete_name
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      rpms = Rpm.in_repositories(@repositories)
      col = "#{Rpm.table_name}.name"
      rpms = rpms.where("#{Rpm.table_name}.name ILIKE ?", "#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      rpms = rpms.modular if ::Foreman::Cast.to_bool(params[:modular_only])
      rpms = rpms.non_modular if ::Foreman::Cast.to_bool(params[:non_modular_only])
      render :json => rpms.pluck(col)
    end

    def auto_complete_arch
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      rpms = Rpm.in_repositories(@repositories)
      col = "#{Rpm.table_name}.arch"
      rpms = rpms.where("#{col} ILIKE ?", "%#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      rpms = rpms.modular if ::Foreman::Cast.to_bool(params[:modular_only])
      rpms = rpms.non_modular if ::Foreman::Cast.to_bool(params[:non_modular_only])
      render :json => rpms.pluck(col)
    end

    api :GET, "/packages", N_("List packages")
    api :GET, "/content_views/:content_view_id/filters/:filter_id/:resource_id", N_("List :resource_id")
    api :GET, "/content_view_filters/:content_view_filter_id/:resource_id", N_("List :resource_id")
    api :GET, "/repositories/:repository_id/:resource_id", N_("List :resource_id")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :content_view_version_id, :number, :desc => N_("Content View Version identifier")
    param :content_view_filter_id, :number, :desc => N_("Content View Filter identifier")
    param :repository_id, :number, :desc => N_("Repository identifier")
    param :environment_id, :number, :desc => N_("Environment identifier")
    param :ids, Array, :desc => N_("Package identifiers to filter content by")
    param :host_id, :number, :desc => N_("Host id to list applicable packages for")
    param :packages_restrict_applicable, :boolean, :desc => N_("Return packages that are applicable to one or more hosts (defaults to true if host_id is specified)")
    param :packages_restrict_upgradable, :boolean, :desc => N_("Return packages that are upgradable on one or more hosts")
    param :packages_restrict_latest, :boolean, :desc => N_("Return only the latest version of each package")
    param :available_for, String, :desc => N_("Return packages that can be added to the specified object.  Only the value 'content_view_version' is supported.")
    param_group :search, ::Katello::Api::V2::ApiController
    def index # rubocop:disable Lint/UselessMethodDefinition
      super
    end

    def available_for_content_view_version(version)
      version.available_packages
    end

    def custom_index_relation(collection)
      applicable = ::Foreman::Cast.to_bool(params[:packages_restrict_applicable]) || params[:host_id]
      upgradable = ::Foreman::Cast.to_bool(params[:packages_restrict_upgradable])
      not_installed = ::Foreman::Cast.to_bool(params[:packages_restrict_not_installed])

      if upgradable
        collection = collection.installable_for_hosts(@hosts)
      elsif not_installed && params[:host_id]
        host = @hosts.first
        collection = Katello::Rpm.yum_installable_for_host(host)
      elsif applicable
        collection = collection.applicable_to_hosts(@hosts)
      end

      collection
    end

    def final_custom_index_relation(collection)
      # :packages_restrict_latest is intended to filter the result set after all
      # other constraints have been applied, including the scoped_search
      # constraints.  If any constraints are applied after this, then a package
      # will not be returned if its latest version does not match those
      # constraints, even if an older version does match those constraints.
      collection = Katello::Rpm.latest(collection) if ::Foreman::Cast.to_bool(params[:packages_restrict_latest])
      collection
    end

    def filter_by_content_view_filter(filter, collection)
      filtered_rpms = []
      filter.package_rules.each do |rule|
        filtered_rpms += filter.query_rpms_from_collection(collection, rule).pluck(:id)
      end

      collection.where(id: filter.applicable_rpms.pluck(:id) & filtered_rpms)
    end

    def filter_by_content_view_filter_rule(rule, collection)
      filter = rule.filter
      filtered_rpms = filter.query_rpms_from_collection(collection, rule).pluck(:id)

      collection.where(id: filter.applicable_rpms.pluck(:id) & filtered_rpms)
    end

    private

    def find_hosts
      @hosts = ::Host::Managed.authorized("view_hosts")
      if params[:host_id]
        @hosts = @hosts.where(:id => params[:host_id])
        fail HttpErrors::NotFound, _('Could not find a host with id %s') % params[:host_id] if @hosts.empty?
      end
      @hosts = @hosts.where(:organization_id => params[:organization_id]) if params[:organization_id]
    end

    def find_repositories
      @repositories = Repository.readable.where(:id => params[:repoids])
    end

    def resource_class
      Katello::Rpm
    end

    def default_sort
      lambda { |query| query.default_sort }
    end
  end
end
