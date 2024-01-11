module Katello
  module Concerns
    module Api::V2::RegistrationCommandsControllerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def registration_args
          args = super
          args['activation_keys'] ||= []

          if args['activation_key'].present?
            args['activation_keys'] << args.delete('activation_key').split(',').map(&:strip).reject(&:blank?).join(',')
          end

          args['activation_keys'] = args['activation_keys'].join(',')
          args.delete('activation_keys') if args['activation_keys'].empty?
          args
        end

        def append_array_of_ids(*)
          return
        end
      end

      module ApiPieExtensions
        extend ::Apipie::DSL::Concern

        update_api(:create) do
          param :registration_command, Hash do
            param :activation_key, String, desc: N_('Activation key for subscription-manager client, required for CentOS and Red Hat Enterprise Linux. For multiple keys use `activation_keys` param instead.'), deprecated: true
            param :activation_keys, Array, desc: N_('Activation keys for subscription-manager client, required for CentOS and Red Hat Enterprise Linux. Required only if host group has no activation keys.')
            param :force, :bool, required: false, desc: N_('Clear any previous registration and run subscription-manager with --force.')
            param :ignore_subman_errors, :bool, required: false, desc: N_('Ignore subscription-manager errors for `subscription-manager register` command')
          end
        end
      end

      included do
        prepend Overrides
        include ApiPieExtensions

        before_action :check_activation_keys, only: [:create]
      end

      private

      def check_activation_keys
        return if params['registration_command']['activation_key'].present? ||
                  params['registration_command']['activation_keys'].present? ||
                  hostgroup_have_acks?

        render_error 'custom_error', status: :unprocessable_entity,
                                     locals: { message: N_('Missing activation key!') }
      end

      def hostgroup_have_acks?
        return unless params['registration_command']['hostgroup_id']

        ::Hostgroup.authorized(:view_hostgroups)
                   .find(params['registration_command']['hostgroup_id'])
                   .params['kt_activation_keys']
                   .present?
      end
    end
  end
end
