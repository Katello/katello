module Actions
  module Pulp
    module Repository
      class RemoveErrata < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.errata
        end

        def criteria
          super.merge(fields: { :unit => ::Katello::Pulp::Erratum::PULP_SELECT_FIELDS})
        end
      end
    end
  end
end
