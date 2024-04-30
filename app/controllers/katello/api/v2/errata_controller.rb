module Katello
  class Api::V2::ErrataController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("an erratum"), :resource => "errata")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_host, :only => [:index]
    before_action :find_optional_organization, :only => [:index, :auto_complete_search]

    api :GET, "/errata", N_("List errata")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :content_view_version_id, :number, :desc => N_("Content View Version identifier")
    param :content_view_filter_id, :number, :desc => N_("Content View Filter identifier. Use to filter by ID")
    param :repository_id, :number, :desc => N_("Repository identifier")
    param :environment_id, :number, :desc => N_("Environment identifier")
    param :cve, String, :desc => N_("CVE identifier")
    param :host_id, :number, :desc => N_("Host id to list applicable errata for")
    param :errata_restrict_applicable, :bool, :desc => N_("Return errata that are applicable to one or more hosts (defaults to true if host_id is specified)")
    param :errata_restrict_installable, :bool, :desc => N_("Return errata that are upgradable on one or more hosts")
    param :available_for, String, :desc => N_("Return errata that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Erratum)
    def index
      super
    end

    def available_for_content_view_version(version)
      version.available_errata
    end

    def available_for_content_view_filter(filter, collection)
      collection = filter_by_content_view(filter, collection)
      ids = Katello::ContentViewErratumFilterRule.where(:content_view_filter_id => filter.id).pluck("errata_id")
      collection = collection.where("errata_id not in (?)", ids) unless ids.empty?
      collection
    end

    def all_for_content_view_filter(filter, _collection)
      available_ids = Erratum.joins(:repositories).merge(filter.applicable_repos)&.pluck(:errata_id) || []
      added_ids = filter&.erratum_rules&.pluck(:errata_id) || []
      Erratum.where(errata_id: available_ids + added_ids)
    end

    def custom_index_relation(collection)
      collection = filter_by_cve(params[:cve], collection) if params[:cve]
      applicable = ::Foreman::Cast.to_bool(params[:errata_restrict_applicable]) || @host
      installable = ::Foreman::Cast.to_bool(params[:errata_restrict_installable])
      if applicable || installable
        hosts = @host ? ::Host::Managed.where(:id => @host.id) : ::Host::Managed.authorized("view_hosts")
        hosts = hosts.where(:organization_id => params[:organization_id]) if params[:organization_id]
        if installable
          collection = collection.where(:id => Erratum.ids_installable_for_hosts(hosts))
        elsif applicable
          collection = collection.applicable_to_hosts(hosts)
        end
      end
      date_type = params[:date_type].present? ? params[:date_type] : ContentViewErratumFilterRule::UPDATED
      unless ContentViewErratumFilterRule::DATE_TYPES.include?(date_type)
        msg = _("Invalid params provided - date_type must be one of %s" % ContentViewErratumFilterRule::DATE_TYPES.join(","))
        fail HttpErrors::UnprocessableEntity, msg
      end

      collection = collection.where("#{date_type} >= ?", params[:start_date]) if params[:start_date]
      collection = collection.where("#{date_type} <= ?", params[:end_date]) if params[:end_date]
      collection = collection.of_type(params[:types]) if params[:types]
      collection
    end

    private

    def find_host
      if params[:host_id]
        @host = ::Host::Managed.authorized("view_hosts").find_by(:id => params[:host_id])
        fail HttpErrors::NotFound, _('Could not find a host with id %s') % params[:host_id] unless @host
      end
    end

    def filter_by_cve(cve, collection)
      collection.joins(:cves).where('katello_erratum_cves.cve_id' => cve)
    end

    def filter_by_content_view(filter, collection)
      repos = Katello::ContentView.find(filter.content_view_id).repositories
      ids = repos.map { |r| r.send(:erratum_ids) }.flatten
      filter_by_ids(ids, collection)
    end

    def filter_by_content_view_filter(filter, collection)
      collection.where(:errata_id => filter.erratum_rules.pluck(:errata_id))
    end

    def default_sort
      %w(updated desc)
    end
  end
end
