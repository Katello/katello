module Katello
  class Api::V2::SystemErrataController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_system
    before_filter :find_errata_ids, :only => :apply
    before_filter :find_environment, :only => :index
    before_filter :find_content_view, :only => :index

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def resource_class
      Erratum
    end

    api :GET, "/systems/:system_id/errata", N_("List errata available for the content host"), :deprecated => true
    param :system_id, :identifier, :desc => N_("UUID of the content host"), :required => true
    param :content_view_id, :number, :desc => N_("Calculate Applicable Errata based on a particular Content View"), :required => false
    param :environment_id, :number, :desc => N_("Calculate Applicable Errata based on a particular Environment"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      if  (params[:content_view_id] && params[:environment_id].nil?) || (params[:environment_id] && params[:content_view_id].nil?)
        fail _("Either both parameters 'content_view_id' and 'environment_id' should be specified or neither should be specified")
      end

      collection = scoped_search(index_relation, 'updated_at', 'desc', :resource_class => Erratum, :includes => [:cves])
      @installable_errata_ids = @system.installable_errata.pluck("#{Katello::Erratum.table_name}.id")
      respond_for_index :collection => collection
    end

    api :PUT, "/systems/:system_id/errata/apply", N_("Schedule errata for installation"), :deprecated => true
    param :system_id, :identifier, :desc => N_("System UUID"), :required => true
    param :errata_ids, Array, :desc => N_("List of Errata ids to install"), :required => true
    def apply
      task = async_task(::Actions::Katello::System::Erratum::Install, @system, params[:errata_ids])
      respond_for_async :resource => task
    end

    api :GET, "/systems/:system_id/errata/:id", N_("Retrieve a single errata for a system"), :deprecated => true
    param :system_id, :identifier, :desc => N_("System UUID"), :required => true
    param :id, String, :desc => N_("Errata id of the erratum (RHSA-2012:108)"), :required => true
    def show
      errata = Erratum.find_by_errata_id(params[:id])
      respond_for_show :resource => errata
    end

    protected

    def index_relation
      @system.installable_errata(@environment, @content_view)
    end

    private

    def find_content_view
      @content_view = ContentView.readable.find(params[:content_view_id]) if params[:content_view_id]
    end

    def find_environment
      @environment = KTEnvironment.readable.find(params[:environment_id]) if params[:environment_id]
    end

    def find_system
      @system = System.where(:uuid => params[:system_id]).first
      fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
      @system
    end

    def find_errata_ids
      missing = params[:errata_ids] - Erratum.where(:errata_id => params[:errata_ids]).pluck(:errata_id)
      fail HttpErrors::NotFound, _("Couldn't find errata ids '%s'") % missing.to_sentence if missing.any?
    end
  end
end
