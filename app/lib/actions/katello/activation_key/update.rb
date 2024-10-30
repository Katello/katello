module Actions
  module Katello
    module ActivationKey
      class Update < Actions::EntryAction
        def plan(activation_key, activation_key_params)
          # need to check if candlepin attributes have changed prior to updating attributes
          update_candlepin = update_candlepin?(activation_key, activation_key_params)
          action_subject activation_key
          activation_key.update!(activation_key_params)
          if update_candlepin
            plan_action(::Actions::Candlepin::ActivationKey::Update,
                        cp_id: activation_key.cp_id,
                        release_version: activation_key.release_version,
                        service_level: activation_key.service_level,
                        auto_attach: activation_key.auto_attach,
                        purpose_role: activation_key.purpose_role,
                        purpose_usage: activation_key.purpose_usage)
          end
        end

        def update_candlepin?(activation_key, activation_key_params)
          cp_changed?(activation_key.auto_attach, activation_key_params[:auto_attach]) ||
          cp_changed?(activation_key.service_level, activation_key_params[:service_level]) ||
          cp_changed?(activation_key.release_version, activation_key_params[:release_version]) ||
          cp_changed?(activation_key.purpose_role, activation_key_params[:purpose_role]) ||
          cp_changed?(activation_key.purpose_usage, activation_key_params[:purpose_usage])
        end

        def cp_changed?(activation_key, activation_key_params)
          !activation_key_params.nil? && activation_key.to_s != activation_key_params.to_s
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
