module Katello
  class Api::V2::ErrataController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("an erratum"), :resource => "errata")
    include Katello::Concerns::Api::V2::RepositoryContentController

    api :GET, "/errata", N_("List errata")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param :environment_id, :number, :desc => N_("environment identifier")
    param :cve, String, :desc => N_("CVE identifier")
    param :errata_restrict_applicable, :bool, :desc => N_("show only errata with one or more applicable hosts")
    param :errata_restrict_installable, :bool, :desc => N_("show only errata with one or more installable hosts")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    def available_for_content_view_filter(filter, collection)
      collection = filter_by_content_view(filter, collection)
      ids = Katello::ContentViewErratumFilterRule.where(:content_view_filter_id => filter.id).pluck("errata_id")
      collection = collection.where("errata_id not in (?)", ids) unless ids.empty?

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

    def custom_index_relation(collection)
      collection = filter_by_cve(params[:cve], collection) if params[:cve]
      hosts = ::Host::Managed.authorized("view_hosts")
      if ::Foreman::Cast.to_bool(params[:errata_restrict_applicable])
        collection = collection.applicable_to_hosts(hosts)
      end

      if ::Foreman::Cast.to_bool(params[:errata_restrict_installable])
        collection = collection.installable_for_hosts(hosts)
      end
      collection
    end

    private

    def filter_by_cve(cve, collection)
      collection.joins(:cves).where('katello_erratum_cves.cve_id' => cve)
    end

    def filter_by_content_view(filter, collection)
      repos = Katello::ContentView.find(filter.content_view_id).repositories
      uuid = repos.map { |r| r.send("errata").pluck("uuid") }
      filter_by_ids(uuid, collection)
    end

    def filter_by_content_view_filter(filter, collection)
      collection.where(:errata_id => filter.erratum_rules.pluck(:errata_id))
    end

    def default_sort
      %w(updated desc)
    end
  end
end
