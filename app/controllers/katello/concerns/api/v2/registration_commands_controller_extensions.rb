module Katello
  module Concerns
    module Api::V2::RegistrationCommandsControllerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def registration_args
          args = super

          if args['activation_key'].present?
            args['activation_keys'] = args['activation_key']
            args.delete('activation_key')
          end

          if args['activation_keys'].present?
            if args['activation_keys'].is_a? String
              args['activation_keys'] = args['activation_keys'].split(',').map(&:strip).reject(&:blank?).join(',')
            end
            if args['activation_keys'].is_a? Array
              args['activation_keys'] = args['activation_keys'].join(',')
            end
          end

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
            param :activation_key, String, desc: N_('Activation key(s) for Subscription Manager. Required for CentOS and Red Hat Enterprise Linux. Multiple keys add separated by comma, example: key1,key2,key3.'), deprecated: true
            param :activation_keys, Array, required: true, desc: N_('Activation key(s) for Subscription Manager. Required for CentOS and Red Hat Enterprise Linux. Required only if hostgroup has no activation keys')
            param :lifecycle_environment_id, :number, required: false, desc: N_('Life cycle environment for the host.')
            param :force, :bool, required: false, desc: N_('Remove any `katello-ca-consumer` rpms before registration and run subscription-manager with `--force` argument.')
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
