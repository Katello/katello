module Katello
  module Concerns
    module BaseTemplateScopeExtensions
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
        Katello::Erratum.in_repositories(Katello::Repository.readable).with_identifiers(id).map(&:attributes).first.slice!('created_at', 'updated_at')
      end
    end
  end
end
