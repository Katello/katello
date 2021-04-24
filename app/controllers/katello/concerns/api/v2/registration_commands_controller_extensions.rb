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

        def append_array_of_ids(hash_params)
          return if registration_params['activation_key'].present? || registration_params['activation_keys'].present?
          super
        end
      end

      module ApiPieExtensions
        extend ::Apipie::DSL::Concern

        update_api(:create) do
          param :registration_command, Hash do
            param :activation_key, String, desc: N_('Activation key for subscription-manager client. Required for CentOS and Red Hat Enterprise Linux. Multiple keys add separated by comma, example: key1,key2,key3.'), deprecated: true
            param :activation_keys, Array, required: true, desc: N_('Activation key(s) for subscription-manager client. Required for CentOS and Red Hat Enterprise Linux. Required only if host group has no activation keys')
            param :lifecycle_environment_id, :number, required: false, desc: N_('Lifecycle environment for the host.')
            param :force, :bool, required: false, desc: N_('Clear any previous registration and run subscription-manager with --force.')
            param :ignore_subman_errors, :bool, required: false, desc: N_('Ignore subscription-manager errors for `subscription-manager register` command')
          end
        end
      end

      included do
        prepend Overrides
        include ApiPieExtensions
      end
    end
  end
end
