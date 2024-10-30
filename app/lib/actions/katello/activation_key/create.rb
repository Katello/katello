module Actions
  module Katello
    module ActivationKey
      class Create < Actions::EntryAction
        def plan(activation_key, params = {})
          activation_key.save!
          cp_create = plan_action(Candlepin::ActivationKey::Create,
                                  organization_label: activation_key.organization.label,
                                  auto_attach: activation_key.auto_attach,
                                  service_level: params[:service_level],
                                  release_version: activation_key.release_version,
                                  purpose_role: activation_key.purpose_role,
                                  purpose_usage: activation_key.purpose_usage)
          cp_id = cp_create.output[:response][:id]
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
