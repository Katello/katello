module Actions
  module Pulp
    module Repository
      class RemoveDeb < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.deb
        end

        def criteria
          super.merge(fields: { :unit => ::Katello::Pulp::Deb::PULP_SELECT_FIELDS})
        end
      end
    end
  end
end
