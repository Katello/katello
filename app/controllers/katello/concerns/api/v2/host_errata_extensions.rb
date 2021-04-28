module Katello
  module Concerns
    module Api::V2::HostErrataExtensions
      extend ActiveSupport::Concern

      def find_bulk_errata_ids(hosts, bulk_errata_ids)
        bulk_params = ActiveSupport::JSON.decode(bulk_errata_ids).deep_symbolize_keys
        bulk_params[:included] ||= {}
        bulk_params[:excluded] ||= {}

        if bulk_params[:included][:ids].blank? && bulk_params[:included][:search].nil?
          fail HttpErrors::BadRequest, _("No errata has been specified.")
        end

        #works on a structure of param_group bulk_params and transforms it into a list of errata_ids
        errata = ::Katello::Erratum.installable_for_hosts(hosts)

        if bulk_params[:included][:ids]
          errata = errata.where(:errata_id => bulk_params[:included][:ids])
        end

        if bulk_params[:included][:search]
          search_errata = ::Katello::Erratum.installable_for_hosts(hosts)
          search_errata = search_errata.search_for(bulk_params[:included][:search])

          if errata.any?
            errata = errata.merge(search_errata)
          else
            errata = search_errata
          end
        end

        if bulk_params[:excluded][:ids].present?
          errata = errata.where.not(errata_id: bulk_params[:excluded][:ids])
        end

        errata.pluck(:errata_id)
      end
    end
  end
end
