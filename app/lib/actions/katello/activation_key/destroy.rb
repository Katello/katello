module Actions
  module Katello
    module ActivationKey
      class Destroy < Actions::EntryAction
        def plan(activation_key, options = {})
          activation_key.validate_destroyable!
          skip_candlepin = options.fetch(:skip_candlepin, false)
          action_subject(activation_key)

          plan_action(Candlepin::ActivationKey::Destroy, cp_id: activation_key.cp_id) if !skip_candlepin && activation_key.cp_id.present?
          plan_self
        end

        def finalize
          activation_key = ::Katello::ActivationKey.find(input[:activation_key][:id])
          activation_key.destroy!
        end

        def humanized_name
          _("Delete Activation Key")
        end
      end
    end
  end
end
