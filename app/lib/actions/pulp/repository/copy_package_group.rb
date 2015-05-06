module Actions
  module Pulp
    module Repository
      class CopyPackageGroup < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.package_group
        end
      end
    end
  end
end
