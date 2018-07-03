module Katello
  module Concerns
    module InputTemplateScopeExtensions
      extend ActiveSupport::Concern

      module Overrides
        def allowed_helpers
          super + [:errata]
        end
      end

      included do
        prepend Overrides
      end

      def errata(id)
        Katello::Erratum.with_identifiers(id).map(&:attributes).first.slice!('created_at', 'updated_at')
      end
    end
  end
end
