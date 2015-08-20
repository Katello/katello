module Actions
  module Pulp
    module Repository
      class CopyRpm < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.rpm
        end

        def criteria
          super.merge(fields: ::Katello::Rpm::PULP_SELECT_FIELDS)
        end
      end
    end
  end
end
