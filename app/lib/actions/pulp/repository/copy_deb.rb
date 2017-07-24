module Actions
  module Pulp
    module Repository
      class CopyDeb < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.deb
        end

        def criteria
          super.merge(fields: ::Katello::Pulp::Deb::PULP_SELECT_FIELDS)
        end
      end
    end
  end
end
