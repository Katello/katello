module Katello
  class Api::V2::DebsController < Api::V2::ApiController
    resource_description do
      name 'Deb Packages'
      resource_id 'debs'
    end
    apipie_concern_subst(:a_resource => N_("a deb package"), :resource => "deb packages")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_hosts, :only => :index
    before_action :find_repositories, :only => [:auto_complete_name, :auto_complete_arch]

    def auto_complete(search)
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      debs = Deb.in_repositories(@repositories)
      col = ''
      if search == 'name'
        col = "#{Deb.table_name}.name"
      elsif search == 'arch'
        col = "#{Deb.table_name}.architecture"
      end
      debs = debs.where("#{col} ILIKE ?", "#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      render :json => debs.pluck(col)
    end

    def auto_complete_name
      auto_complete('name')
    end

    def auto_complete_arch
      auto_complete('architecture')
    end

    api :GET, "/debs", N_("List deb packages")
    api :GET, "/content_views/:content_view_id/filters/:filter_id/debs", N_("List deb packages")
    api :GET, "/content_view_filters/:content_view_filter_id/debs", N_("List deb packages")
    api :GET, "/repositories/:repository_id/debs", N_("List deb packages")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :content_view_version_id, :number, :desc => N_("Content View Version identifier")
    param :content_view_filter_id, :number, :desc => N_("Content View Filter identifier")
    param :repository_id, :number, :desc => N_("Repository identifier")
    param :environment_id, :number, :desc => N_("Environment identifier")
    param :ids, Array, :desc => N_("Deb package identifiers to filter content by")
    param :host_id, :number, :desc => N_("Host id to list applicable deb packages for")
    param :packages_restrict_applicable, :boolean, :desc => N_("Return deb packages that are applicable to one or more hosts (defaults to true if host_id is specified)")
    param :packages_restrict_upgradable, :boolean, :desc => N_("Return deb packages that are upgradable on one or more hosts")
    param :packages_restrict_latest, :boolean, :desc => N_("Return only the latest version of each package")
    param :available_for, String, :desc => N_("Return deb packages that can be added to the specified object.  Only the value 'content_view_version' is supported.")
    param_group :search, ::Katello::Api::V2::ApiController
    def index
      super
    end

    def final_custom_index_relation(collection)
      # :packages_restrict_latest is intended to filter the result set after all
      # other constraints have been applied, including the scoped_search
      # constraints.  If any constraints are applied after this, then a package
      # will not be returned if its latest version does not match those
      # constraints, even if an older version does match those constraints.
      collection = Katello::Deb.latest(collection) if ::Foreman::Cast.to_bool(params[:packages_restrict_latest])
      collection
    end

    def filter_by_content_view_filter(filter, collection)
      filtered_debs = []
      filter.deb_rules.each do |rule|
        filtered_debs += filter.query_debs_from_collection(collection, rule).pluck(:id)
      end

      collection.where(id: filter.applicable_debs.pluck(:id) & filtered_debs)
    end

    def filter_by_content_view_filter_rule(rule, collection)
      filter = rule.filter
      filtered_debs = filter.query_debs_from_collection(collection, rule).pluck(:id)
      collection.where(id: filter.applicable_debs.pluck(:id) & filtered_debs)
    end

    def default_sort
      lambda { |query| query.default_sort }
      # %w(name asc)
    end

    def available_for_content_view_version(version)
      version.available_debs
    end

    def custom_index_relation(collection)
      applicable = ::Foreman::Cast.to_bool(params[:packages_restrict_applicable]) || params[:host_id]
      upgradable = ::Foreman::Cast.to_bool(params[:packages_restrict_upgradable])

      if upgradable
        collection = collection.installable_for_hosts(@hosts)
      elsif applicable
        collection = collection.applicable_to_hosts(@hosts)
      end

      collection
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
      Katello::Deb
    end

    def repo_association
      :repository_id
    end
  end
end
