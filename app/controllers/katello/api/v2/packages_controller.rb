module Katello
  class Api::V2::PackagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package"), :resource => "packages")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_repositories, :only => [:auto_complete_name, :auto_complete_arch]
    before_action :find_host, :only => :index

    def auto_complete_name
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      rpms = Rpm.in_repositories(@repositories)
      col = "#{Rpm.table_name}.name"
      rpms = rpms.where("#{Rpm.table_name}.name ILIKE ?", "#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      render :json => rpms.pluck(col)
    end

    def auto_complete_arch
      page_size = Katello::Concerns::FilteredAutoCompleteSearch::PAGE_SIZE
      rpms = Rpm.in_repositories(@repositories)
      col = "#{Rpm.table_name}.arch"
      rpms = rpms.where("#{col} ILIKE ?", "%#{params[:term]}%").select(col).group(col).order(col).limit(page_size)
      render :json => rpms.pluck(col)
    end

    api :GET, "/packages", N_("List packages")
    api :GET, "/content_views/:content_view_id/filters/:filter_id/:resource_id", N_("List :resource_id")
    api :GET, "/content_view_filters/:content_view_filter_id/:resource_id", N_("List :resource_id")
    api :GET, "/repositories/:repository_id/:resource_id", N_("List :resource_id")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param :environment_id, :number, :desc => N_("environment identifier")
    param :ids, Array, :desc => N_("ids to filter content by")
    param :host_id, :number, :desc => N_("host id to list applicable packages for")
    param :packages_restrict_upgradable, :boolean, :desc => N_("Only show packages that are upgradable in the host(s) Content View.")
    param :packages_restrict_applicable, :boolean, :desc => N_("Only show packages that are applicable to hosts (defaults to true if host_id is specified)")
    param_group :search, ::Katello::Api::V2::ApiController
    def index
      super
    end

    def custom_index_relation(collection)
      if ::Foreman::Cast.to_bool(params[:packages_restrict_upgradable])
        if @host
          collection = collection.installable_for_hosts([@host])
        else
          hosts = ::Host::Managed.authorized("view_hosts")
          hosts = hosts.where(:organization_id => params[:organization_id]) if params[:organization_id]
          collection = collection.installable_for_hosts(hosts)
        end
      elsif ::Foreman::Cast.to_bool(params[:packages_restrict_applicable]) || @host
        if @host
          collection = collection.applicable_to_hosts([@host])
        else
          hosts = ::Host::Managed.authorized("view_hosts")
          hosts = hosts.where(:organization_id => params[:organization_id]) if params[:organization_id]
          collection = collection.applicable_to_hosts(hosts)
        end
      end

      collection
    end

    def find_host
      if params[:host_id]
        @host = ::Host::Managed.authorized("view_hosts").find_by(:id => params[:host_id])
        fail HttpErrors::NotFound, _('Could not find a host with id %s') % params[:host_id] unless @host
      end
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
