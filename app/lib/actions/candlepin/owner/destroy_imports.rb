module Actions
  module Candlepin
    module Owner
      class DestroyImports < Candlepin::Abstract
        input_format do
          param :label
        end

        def run
          organization = ::Organization.find_by!(label: input[:label])
          output[:response] = ::Katello::Resources::Candlepin::Owner.destroy_imports(organization.label, wait_until_complete: true)
          organization.redhat_provider.index_subscriptions
        end
      end
    end
  end
end
