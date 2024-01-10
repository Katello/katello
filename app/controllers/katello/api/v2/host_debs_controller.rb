module Katello
  class Api::V2::HostDebsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/debs", N_("List deb packages installed on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param :include_latest_upgradable, :boolean, :desc => N_("Also include the latest upgradable package version for each host package")
    param :status, String, :desc => N_("Return only packages of a particular status (upgradable or up-to-date)"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Katello::InstalledDeb)
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => ::Katello::InstalledDeb)
      collection[:results] = HostDebPresenter.with_latest(collection[:results], @host) if ::Foreman::Cast.to_bool(params[:include_latest_upgradable])
      respond_for_index(:collection => collection)
    end

    def index_relation
      packages = @host.installed_debs
      upgradable_packages = ::Katello::Deb.installable_for_hosts([@host]).select(:name)
      if params[:status].present?
        packages = case params[:status]
                   when 'up-to-date' then packages.where.not(name: upgradable_packages)
                   when 'upgradable' then packages.where(name: upgradable_packages)
                   end
      end
      packages
    end

    def resource_class
      Katello::InstalledDeb
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
      throw_resource_not_found(name: 'host', id: params[:host_id]) if @host.nil?
    end
  end
end
