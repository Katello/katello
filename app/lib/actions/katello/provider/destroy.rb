module Actions
  module Katello
    module Provider
      class Destroy < Actions::EntryAction
        def plan(provider, check_products = true)
          fail _("Red Hat provider can not be deleted") if !provider.being_deleted? && provider.redhat_provider?
          fail _("Cannot delete provider with attached products") if check_products && !provider.products.empty?
          action_subject(provider)

          plan_self
        end

        def finalize
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.destroy!
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
