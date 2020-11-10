module Actions
  module Katello
    module Organization
      class Create < Actions::EntryAction
        def plan(organization)
          organization.setup_label_from_name
          organization.create_library
          organization.create_anonymous_provider unless organization.anonymous_provider
          organization.create_redhat_provider unless organization.redhat_provider
          cp_create = nil

          organization.save!

          sequence do
            cp_create = plan_action(Candlepin::Owner::Create,
                                    label:  organization.label,
                                    name: organization.name)
            plan_action(Katello::Environment::LibraryCreate, organization.library)
          end
          if cp_create
            action_subject organization, label: cp_create.output[:response][:key]
          else
            action_subject organization
          end
          plan_self(:organization_id => organization.id)
        end

        def run
          ::Organization.find_by(:id => input[:organization_id]).try(:load_debug_cert)
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
