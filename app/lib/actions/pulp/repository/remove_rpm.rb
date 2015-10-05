module Actions
  module Pulp
    module Repository
      class RemoveRpm < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.rpm
        end

        def criteria
          super.merge(fields: { :unit => ::Katello::Pulp::Rpm::PULP_SELECT_FIELDS})
        end
      end
    end
  end
end
