module Actions
  module Pulp
    module Repository
      class CopyErrata < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.errata
        end

        def criteria
          super.merge(fields: ::Katello::Pulp::Erratum::PULP_SELECT_FIELDS)
        end
      end
    end
  end
end
