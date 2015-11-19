module Katello
  module Concerns
    module Api::V2::BulkSystemsExtensions
      extend ActiveSupport::Concern

      def find_bulk_systems(perm_method, bulk_params, restrict_to = nil)
        #works on a structure of param_group bulk_params and transforms it into a list of systems
        organization = find_organization
        bulk_params[:included] ||= {}
        bulk_params[:excluded] ||= {}
        @systems = []

        unless bulk_params[:included][:ids].blank?
          @systems = System.send(perm_method).where(:uuid => bulk_params[:included][:ids])
          @systems = @systems.where(:environment_id => organization.kt_environments) if organization
          @systems = @systems.where('uuid not in (?)', bulk_params[:excluded]) unless bulk_params[:excluded][:ids].blank?
          @systems = restrict_to.call(@systems) if restrict_to
        end

        if bulk_params[:included][:search]
          search_systems = System.where(:id => Organization.find(params[:organization_id]).systems.map(&:id)) if params[:organization_id]
          search_systems = search_systems.search_for(bulk_params[:included][:search])
          @systems += search_systems
        end

        if bulk_params[:included][:ids].blank? && bulk_params[:included][:search].nil?
          fail HttpErrors::BadRequest, _("No systems have been specified.")
        elsif @systems.empty?
          fail HttpErrors::Forbidden, _("Action unauthorized to be performed on selected systems.")
        end
        @systems
      end

      def find_organization
        Organization.find_by_id(params[:organization_id])
      end
    end
  end
end
