module Actions
  module Katello
    module ActivationKey
      class Create < Actions::EntryAction
        def plan(activation_key)
          activation_key.save!
          if ::SETTINGS[:katello][:use_cp]
            cp_create = plan_action(Candlepin::ActivationKey::Create,
                                    organization_label: activation_key.organization.label,
                                    auto_attach: activation_key.auto_attach)
            cp_id = cp_create.output[:response][:id]
          end
          action_subject(activation_key, :cp_id => cp_id)
          plan_self
        end

        def humanized_name
          _("Create")
        end

        def finalize
          activation_key = ::Katello::ActivationKey.find(input[:activation_key][:id])
          activation_key.cp_id = input[:cp_id]
          activation_key.save!
        end
      end
    end
  end
end
