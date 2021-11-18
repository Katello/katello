module Katello
  class Api::V2::HostPackagesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :require_packages_or_groups, :only => [:install, :remove]
    before_action :require_packages_only, :only => [:upgrade]
    before_action :find_editable_host_with_facet, :except => :index
    before_action :find_host, :only => :index
    before_action :deprecate_katello_agent, :only => [:install, :remove, :upgrade, :upgrade_all]

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def_param_group :packages_or_groups do
      param :packages, Array, :desc => N_("List of package names"), :required => false
      param :groups, Array, :desc => N_("List of package group names (Deprecated)"), :required => false
    end

    api :GET, "/hosts/:host_id/packages", N_("List packages installed on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param :include_latest_upgradable, :boolean, :desc => N_("Also include the latest upgradable package version for each host package")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Katello::InstalledPackage)
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => ::Katello::InstalledPackage)
      collection[:results] = HostPackagePresenter.with_latest(collection[:results], @host) if ::Foreman::Cast.to_bool(params[:include_latest_upgradable])
      respond_for_index(:collection => collection)
    end

    api :PUT, "/hosts/:host_id/packages/install", N_("Install packages remotely using katello-agent. %s") % katello_agent_deprecation_text, deprecated: true
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param_group :packages_or_groups
    def install
      if params[:packages]
        packages = validate_package_list_format(params[:packages])
        task     = async_task(::Actions::Katello::Host::Package::Install, @host, content: packages)
        respond_for_async :resource => task
        return
      end

      if params[:groups]
        groups = extract_group_names(params[:groups])
        task   = async_task(::Actions::Katello::Host::PackageGroup::Install, @host, content: groups)
        respond_for_async :resource => task
      end
    end

    api :PUT, "/hosts/:host_id/packages/upgrade", N_("Update packages remotely using katello-agent. %s") % katello_agent_deprecation_text, deprecated: true
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param :packages, Array, :desc => N_("list of packages names"), :required => true
    def upgrade
      if params[:packages]
        packages = validate_package_list_format(params[:packages])
        task     = async_task(::Actions::Katello::Host::Package::Update, @host, content: packages)
        respond_for_async :resource => task
      end
    end

    api :PUT, "/hosts/:host_id/packages/upgrade_all", N_("Update packages remotely using katello-agent. %s") % katello_agent_deprecation_text, deprecated: true
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    def upgrade_all
      task = async_task(::Actions::Katello::Host::Package::Update, @host, content: [])
      respond_for_async :resource => task
    end

    api :PUT, "/hosts/:host_id/packages/remove", N_("Uninstall packages remotely using katello-agent. %s") % katello_agent_deprecation_text, deprecated: true
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param_group :packages_or_groups
    def remove
      if params[:packages]
        packages = validate_package_list_format(params[:packages])
        task     = async_task(::Actions::Katello::Host::Package::Remove, @host, content: packages)
        respond_for_async :resource => task
        return
      end

      if params[:groups]
        groups = extract_group_names(params[:groups])
        task   = async_task(::Actions::Katello::Host::PackageGroup::Remove, @host, content: groups)
        respond_for_async :resource => task
      end
    end

    def index_relation
      @host.installed_packages
    end

    def resource_class
      Katello::InstalledPackage
    end

    private

    def find_editable_host_with_facet
      @host = resource_finder(::Host::Managed.authorized("edit_hosts"), params[:host_id])
      fail HttpErrors::NotFound, _("Couldn't find host with host id '%s'") % params[:host_id] if @host.nil?
      if @host.content_facet.try(:uuid).nil?
        fail HttpErrors::NotFound, _("Host has not been registered with subscription-manager.") % params[:host_id]
      end
      @host
    end

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end

    def validate_package_list_format(packages)
      packages.each do |package|
        unless package.is_a?(String) && ::Katello::Util::Package.valid_package_name_format(package).nil?
          fail HttpErrors::BadRequest, _("%s is not a valid package name") % package
        end
      end

      return packages
    end

    def require_packages_or_groups
      if params.slice(:packages, :groups).values.size != 1
        fail HttpErrors::BadRequest, _("Either packages or groups must be provided")
      end
    end

    def require_packages_only
      if params[:groups]
        fail HttpErrors::BadRequest, _("This action doesn't support package groups")
      end

      unless params[:packages]
        fail HttpErrors::BadRequest, _("Packages must be provided")
      end
    end

    def extract_group_names(groups)
      groups.map do |group|
        group.gsub(/^@/, "")
      end
    end
  end
end
