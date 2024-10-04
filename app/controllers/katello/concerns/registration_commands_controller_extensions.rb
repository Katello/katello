module Katello
  module Concerns
    module RegistrationCommandsControllerExtensions
      extend ActiveSupport::Concern

      def plugin_data
        aks = ActivationKey.authorized(:view_activation_keys)
                           .where(organization_id: registration_params[:organization_id])
                           .order(:name)
                           .map { |ak| { name: ak.name, cves: ak.content_view_environments.map(&:label).join(', ') } }

        lces = KTEnvironment.readable
                            .where(organization_id: registration_params[:organization_id])
                            .order(:name)

        data = { activationKeys: aks, lifecycleEnvironments: lces }

        if registration_params[:hostgroup_id].present?
          host_group = ::Hostgroup.authorized(:view_hostgroups).find(registration_params[:hostgroup_id])
          data[:hostGroupActivationKeys] = host_group.params['kt_activation_keys']
          data[:hostGroupEnvironment] = host_group.lifecycle_environment&.name
        end

        super.merge(data)
      end

      def registration_args
        args = super
        args['activation_keys'] = args['activation_keys'].join(',') if args['activation_keys']
        args
      end
    end
  end
end
