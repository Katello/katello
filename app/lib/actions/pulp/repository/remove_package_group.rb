module Actions
  module Pulp
    module Repository
      class RemovePackageGroup < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.package_group
        end
      end
    end
  end
end
