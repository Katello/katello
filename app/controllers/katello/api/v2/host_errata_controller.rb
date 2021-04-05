module Katello
  class Api::V2::HostErrataController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host, only: :index
    before_action :find_host_editable, except: :index
    before_action :find_errata_ids, only: :apply
    before_action :find_environment, only: :index
    before_action :find_content_view, only: :index
    before_action :deprecate_katello_agent, only: :apply

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def resource_class
      Erratum
    end

    def_param_group :bulk_errata_ids do
      param :included, Hash, :desc => N_("Errata to exclusively include in the action"), :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for erratum to perform an action on")
        param :ids, Array, :required => false, :desc => N_("List of errata ids to perform an action on, (ex: RHSA-2019:1168)")
      end
      param :excluded, Hash, :desc => N_("Errata to explicitly exclude in the action."\
                                         " All other applicable errata will be included in the action,"\
                                         " unless an included parameter is passed as well."), :required => true, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of errata ids to exclude and not run an action on, (ex: RHSA-2019:1168)")
      end
    end

    api :GET, "/hosts/:host_id/errata", N_("List errata available for the content host")
    param :host_id, :number, :desc => N_("UUID of the content host"), :required => true
    param :content_view_id, :number, :desc => N_("Calculate Applicable Errata based on a particular Content View"), :required => false
    param :environment_id, :number, :desc => N_("Calculate Applicable Errata based on a particular Environment"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      if (params[:content_view_id] && params[:environment_id].nil?) || (params[:environment_id] && params[:content_view_id].nil?)
        fail _("Either both parameters 'content_view_id' and 'environment_id' should be specified or neither should be specified")
      end

      collection = scoped_search(index_relation, 'updated', 'desc', :resource_class => Erratum, :includes => [:cves])

      @installable_errata_ids = []
      if @host.content_facet
        @installable_errata_ids = @host.content_facet.installable_errata.pluck("#{Katello::Erratum.table_name}.id")
      end

      respond_for_index :collection => collection
    end

    api :PUT, "/hosts/:host_id/errata/apply", N_("Schedule errata for installation")
    param :host_id, :number, :desc => N_("Host ID"), :required => true
    param :errata_ids, Array, :desc => N_("List of Errata ids to install. Will be removed in Katello 4.1."), :required => false, :deprecated => true

    param_group :bulk_errata_ids
    def apply
      task = async_task(::Actions::Katello::Host::Erratum::Install, @host, content: @errata_ids)
      respond_for_async :resource => task
    end

    api :GET, "/hosts/:host_id/errata/:id", N_("Retrieve a single errata for a host")
    param :host_id, :number, :desc => N_("Host ID"), :required => true
    param :id, String, :desc => N_("Errata id of the erratum (RHSA-2012:108)"), :required => true
    def show
      errata = Erratum.find_by(:errata_id => params[:id])
      fail HttpErrors::NotFound, _("Couldn't find errata ids '%s'") % params[:id] unless errata
      respond_for_show :resource => errata
    end

    api :PUT, "/hosts/:host_id/errata/applicability", N_("Force regenerate applicability.")
    param :host_id, :number, :desc => N_("Host ID"), :required => true
    def applicability
      task = async_task(::Actions::Katello::Host::GenerateApplicability, [@host], false)
      respond_for_async :resource => task
    end

    def find_bulk_errata_ids(bulk_params)
      #works on a structure of param_group bulk_params and transforms it into a list of errata_ids
      bulk_params[:included] ||= {}
      bulk_params[:excluded] ||= {}
      @errata = []

      unless bulk_params[:included][:ids].blank?
        @errata = @host.content_facet.installable_errata.where(:errata_id => bulk_params[:included][:ids])
      end

      if bulk_params[:included][:search]
        search_errata = @host.content_facet.installable_errata
        search_errata = search_errata.search_for(bulk_params[:included][:search])
        if @errata.any?
          @errata = ::Katello::Erratum.where(errata_id: @errata).or(::Katello::Erratum.where(errata_id: search_errata))
        else
          @errata = search_errata
        end
      end

      @errata = @errata.where.not(errata_id: bulk_params[:excluded][:ids]) unless @errata.empty? || bulk_params[:excluded][:ids].blank?

      if bulk_params[:included][:ids].blank? && bulk_params[:included][:search].nil?
        fail HttpErrors::BadRequest, _("No errata has been specified.")
      end
      @errata.pluck(:errata_id)
    end

    protected

    def index_relation
      relation = Katello::Erratum.none
      if @host.content_facet
        relation = @host.content_facet.installable_errata(@environment, @content_view)
      end
      relation
    end

    private

    def find_content_view
      @content_view = ContentView.readable.find(params[:content_view_id]) if params[:content_view_id]
    end

    def find_environment
      @environment = KTEnvironment.readable.find(params[:environment_id]) if params[:environment_id]
    end

    def find_host
      @host = resource_finder(::Host::Managed.authorized("view_hosts"), params[:host_id])
      throw_resource_not_found(name: 'host', id: params[:host_id]) if @host.nil?
      @host
    end

    def find_host_editable
      @host = resource_finder(::Host::Managed.authorized("edit_hosts"), params[:host_id])
      throw_resource_not_found(name: 'host', id: params[:host_id]) if @host.nil?
      @host
    end

    def find_errata_ids
      if params[:errata_ids]
        missing = params[:errata_ids] - Erratum.where(:errata_id => params[:errata_ids]).pluck(:errata_id)
        fail HttpErrors::NotFound, _("Couldn't find errata ids '%s'") % missing.to_sentence if missing.any?
        @errata_ids = params[:errata_ids]
      else
        @errata_ids = find_bulk_errata_ids(params[:bulk_errata_ids])
      end
    end
  end
end
