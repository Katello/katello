module Katello
  module Concerns
    module Api::V2::BulkHostsExtensions
      extend ActiveSupport::Concern

      def bulk_hosts_relation(permission, org)
        relation = ::Host::Managed.authorized(permission)
        relation = relation.where(organization: org) if org
        relation
      end

      def find_bulk_hosts(permission, bulk_params, restrict_to = nil)
        #works on a structure of param_group bulk_params and transforms it into a list of systems
        bulk_params[:included] ||= {}
        bulk_params[:excluded] ||= {}

        if !params[:install_all] && bulk_params[:included][:ids].blank? && bulk_params[:included][:search].nil?
          fail HttpErrors::BadRequest, _("No hosts have been specified.")
        end

        find_organization
        @hosts = bulk_hosts_relation(permission, @organization)

        if bulk_params[:included][:ids].present?
          @hosts = @hosts.where(id: bulk_params[:included][:ids])
        end

        if bulk_params[:included][:search].present?
          @hosts = @hosts.search_for(bulk_params[:included][:search])
        end

        @hosts = restrict_to.call(@hosts) if restrict_to

        if bulk_params[:excluded][:ids].present?
          @hosts = @hosts.where.not(id: bulk_params[:excluded][:ids])
        end
        fail HttpErrors::Forbidden, _("No hosts matched search, or action unauthorized for selected hosts.") if @hosts.empty?

        @hosts
      end

      def find_organization
        @organization ||= Organization.find_by_id(params[:organization_id])
      end
    end
  end
end
