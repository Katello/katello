module Actions
  module Pulp
    module Repository
      class CopySrpm < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.srpm
        end

        def criteria
          #Use the same RPM select fields
          super.merge(fields: ::Katello::Pulp::Srpm::PULP_SELECT_FIELDS)
        end
      end
    end
  end
end
