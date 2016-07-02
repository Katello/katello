module Actions
  module Pulp
    module Repository
      class RemoveFile < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.file
        end

        def criteria
          super.merge(fields: { :unit => ::Katello::Pulp::FileUnit::PULP_SELECT_FIELDS})
        end
      end
    end
  end
end
